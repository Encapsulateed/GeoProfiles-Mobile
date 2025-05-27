import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

// Project detail with map, isolines and line selection
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

  // ────────────── WKT helpers ──────────────
  final _numReg = RegExp(r'[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?');

  List<double> _extractNumbers(String wkt) =>
      _numReg.allMatches(wkt).map((m) => double.parse(m.group(0)!)).toList();

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

  // ────────────── Isolines ──────────────
  static const _isoColor = Color(0xFF5E5E5E); // тёмно-серый
  static const double _isoWidth = 2.4;

  List<Polyline> _buildIsolines() {
    if (_project?.isolines == null) return [];
    final res = <Polyline>[];
    for (final iso in _project!.isolines!) {
      final w = iso.geomWkt;
      if (w == null) continue;
      if (w.startsWith('LINESTRING')) {
        res.add(Polyline(points: _parseLine(w), strokeWidth: _isoWidth, color: _isoColor));
      } else if (w.startsWith('POLYGON')) {
        for (final ring in _parsePolygon(w)) {
          res.add(Polyline(points: ring, strokeWidth: _isoWidth, color: _isoColor));
        }
      }
    }
    return res;
  }

  // ────────────── UI actions ──────────────
  void _onTap(TapPosition _, LatLng latlng) => setState(() {
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

  // ────────────── Build ──────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bounds = _boundsFromPolygon(_project?.bboxWkt);
    final isoPolylines = _buildIsolines();

    final markers = <Marker>[];
    if (_start != null) markers.add(_mk(_start!));
    if (_end != null) markers.add(_mk(_end!));

    final selLine = (_start != null && _end != null)
        ? Polyline(points: [_start!, _end!], strokeWidth: 2.5, color: Colors.blue)
        : null;
    final polys = [...isoPolylines, if (selLine != null) selLine];

    return Scaffold(
      appBar: AppBar(title: Text(_project?.name ?? 'Project')),
      bottomNavigationBar: const _BottomNav(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    center: bounds?.center ?? LatLng(0, 0),
                    zoom: 13,
                    interactiveFlags: InteractiveFlag.all,
                    onTap: _onTap,
                    bounds: bounds,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (polys.isNotEmpty) PolylineLayer(polylines: polys),
                    if (markers.isNotEmpty) MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _clear, child: const Text('CLEAR'))),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: (_start != null && _end != null) ? _submit : null,
                    child: const Text('PROFILE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _mk(LatLng p) => Marker(point: p, width: 14, height: 14, builder: (_) => const _BlueDot());
}


class _BlueDot extends StatelessWidget {
  const _BlueDot();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
  );
}


class _BottomNav extends StatelessWidget {
  const _BottomNav();
  @override
  Widget build(BuildContext context) {
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
}
