import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

class ProjectMapPage extends StatefulWidget {
  final String? projectId;
  const ProjectMapPage({Key? key, required this.projectId}) : super(key: key);

  @override
  State<ProjectMapPage> createState() => _ProjectMapPageState();
}

class _ProjectMapPageState extends State<ProjectMapPage> {
  late final ApiService _api;
  ProjectDto? _project;
  LatLng? _start;
  LatLng? _end;
  bool _loading = true;
  double _zoom = 13.0;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _loadProject();
  }

  Future<void> _loadProject() async {
    if (widget.projectId == null) return;
    try {
      final pr = await _api.getProjectById(id: widget.projectId!);
      if (mounted) setState(() => _project = pr);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load project: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<double> _extractNumbers(String wkt) {
    final numReg = RegExp(r'[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?');
    return numReg.allMatches(wkt).map((m) => double.parse(m.group(0)!)).toList();
  }

  List<LatLng> _toLatLng(List<double> nums) {
    final pts = <LatLng>[];
    for (var i = 0; i + 1 < nums.length; i += 2) {
      pts.add(LatLng(nums[i + 1], nums[i]));
    }
    return pts;
  }

  List<LatLng> _parseLine(String wkt) => _toLatLng(_extractNumbers(wkt));

  List<List<LatLng>> _parsePolygon(String wkt) {
    final body = wkt.substring(wkt.indexOf('((') + 2, wkt.lastIndexOf('))'));
    final rings = body.split('),(');
    return rings.map((r) => _toLatLng(_extractNumbers(r))).toList();
  }

  LatLngBounds? _boundsFromPolygon(String? wkt) {
    if (wkt == null || !wkt.startsWith('POLYGON')) return null;
    final pts = _parsePolygon(wkt).expand((e) => e).toList();
    if (pts.isEmpty) return null;
    var swLat = pts.first.latitude, swLon = pts.first.longitude;
    var neLat = pts.first.latitude, neLon = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < swLat) swLat = p.latitude;
      if (p.longitude < swLon) swLon = p.longitude;
      if (p.latitude > neLat) neLat = p.latitude;
      if (p.longitude > neLon) neLon = p.longitude;
    }
    return LatLngBounds(LatLng(swLat, swLon), LatLng(neLat, neLon));
  }

  List<Polyline> _buildIsolines() {
    if (_project?.isolines == null) return [];
    final res = <Polyline>[];
    final totalLines = _project!.isolines!.length;
    final baseColor = const Color(0xFF4A6572); // Приглушенный сине-серый

    for (int i = 0; i < totalLines; i++) {
      final iso = _project!.isolines![i];
      final w = iso.geomWkt;
      if (w == null) continue;

      // Градиент от темного к светлому
      final color = Color.lerp(
          baseColor,
          baseColor.withOpacity(0.5),
          i / (totalLines - 1)
      )!;

      if (w.startsWith('LINESTRING')) {
        res.add(Polyline(
          points: _parseLine(w),
          strokeWidth: 2.5,
          color: color,
        ));
      } else if (w.startsWith('POLYGON')) {
        for (final ring in _parsePolygon(w)) {
          res.add(Polyline(
            points: ring,
            strokeWidth: 2.5,
            color: color,
          ));
        }
      }
    }
    return res;
  }

  void _onTap(TapPosition position, LatLng latlng) => setState(() {
    if (_start == null) {
      _start = latlng;
    } else {
      _end = latlng;
    }
  });

  void _clear() => setState(() {
    _start = null;
    _end = null;
  });

  void _fitBounds() {
    final bounds = _boundsFromPolygon(_project?.bboxWkt);
    if (bounds != null) {
      _mapController.fitBounds(bounds);
    }
  }

  Future<void> _submit() async {
    if (_start == null || _end == null) return;
    try {
      final resp = await _api.createProfile(
        projectId: widget.projectId!,
        start: [_start!.longitude, _start!.latitude],
        end: [_end!.longitude, _end!.latitude],
      );
      if (!mounted) return;
      Navigator.pushNamed(context, '/profileDetail', arguments: <String, String>{
        'projectId': widget.projectId!,
        'profileId' : resp.profileId ?? '',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bounds = _boundsFromPolygon(_project?.bboxWkt);
    final isoPolylines = _buildIsolines();

    final markers = <Marker>[];
    if (_start != null) markers.add(_mk(_start!, Colors.blue));
    if (_end != null) markers.add(_mk(_end!, Colors.red));

    final selLine = (_start != null && _end != null)
        ? Polyline(
      points: [_start!, _end!],
      strokeWidth: 4.0,
      color: Colors.blue.shade700, // Красивый синий цвет
      isDotted: true, // Пунктир для лучшей видимости
    )
        : null;
    final polys = [...isoPolylines, if (selLine != null) selLine];

    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fitBounds,
            tooltip: 'Fit to area',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: bounds?.center ?? const LatLng(0, 0),
                    zoom: _zoom,
                    interactiveFlags: InteractiveFlag.all,
                    onTap: _onTap,
                    bounds: bounds,
                    onMapReady: () {
                      if (bounds != null) {
                        _mapController.fitBounds(bounds);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (polys.isNotEmpty) PolylineLayer(polylines: polys),
                    if (markers.isNotEmpty) MarkerLayer(markers: markers),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'zoomIn',
                              onPressed: () => _mapController.move(_mapController.center, _mapController.zoom + 0.5),
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'zoomOut',
                              onPressed: () => _mapController.move(_mapController.center, _mapController.zoom - 0.5),
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.clear, size: 20),
                    label: const Text('CLEAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_start != null && _end != null) ? _submit : null,
                    icon: const Icon(Icons.terrain, size: 20),
                    label: const Text('PROFILE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_start != null && _end != null)
                          ? Colors.blue.shade600
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        switch (i) {
          case 0:
            Navigator.pop(context);
            break;
          case 1:
            Navigator.pushNamed(context, '/profile');
            break;
          case 2:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }

  Marker _mk(LatLng p, Color color) => Marker(
    point: p,
    width: 24,
    height: 24,
    builder: (ctx) => _ColoredDot(color: color),
  );
}

class _ColoredDot extends StatelessWidget {
  final Color color;
  const _ColoredDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    ),
  );
}