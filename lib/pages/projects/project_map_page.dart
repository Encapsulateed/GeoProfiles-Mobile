// ignore_for_file: public_member_api_docs, unnecessary_null_checks

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  final _mapKey = GlobalKey(); // для скрина

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
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── utils WKT -> LatLng ───
  List<double> _nums(String wkt) =>
      RegExp(r'[-+]?\d+(?:\.\d+)?').allMatches(wkt).map((m) => double.parse(m.group(0)!)).toList();

  List<LatLng> _toLatLng(List<double> ns) =>
      [for (int i = 0; i + 1 < ns.length; i += 2) LatLng(ns[i + 1], ns[i])];

  List<LatLng> _line(String wkt) => _toLatLng(_nums(wkt));

  List<List<LatLng>> _polygon(String wkt) {
    final body = wkt.substring(wkt.indexOf('((') + 2, wkt.lastIndexOf('))'));
    return body.split('),(').map((r) => _toLatLng(_nums(r))).toList();
  }

  LatLngBounds? _boundsFromPolygon(String? wkt) {
    if (wkt == null || !wkt.startsWith('POLYGON')) return null;
    final pts = _polygon(wkt).expand((e) => e).toList();
    if (pts.isEmpty) return null;
    var swLat = pts.first.latitude, swLon = pts.first.longitude;
    var neLat = pts.first.latitude, neLon = pts.first.longitude;
    for (final p in pts) {
      swLat = min(swLat, p.latitude);
      swLon = min(swLon, p.longitude);
      neLat = max(neLat, p.latitude);
      neLon = max(neLon, p.longitude);
    }
    return LatLngBounds(LatLng(swLat, swLon), LatLng(neLat, neLon));
  }

  Color _levelColor(double level, double min, double max) {
    final t = (level - min) / (max - min);
    final k = 0.25 + 0.5 * t;
    final v = (k * 255).round();
    return Color.fromARGB(255, v, v, v);
  }
  List<Polyline> _buildIsolines() {
    if (_project?.isolines == null || _project!.isolines!.isEmpty) return [];

    final levels = _project!.isolines!
        .map((i) => i.level ?? 0)
        .toList()
      ..sort();
    final minL = levels.first;
    final maxL = levels.last;

    return [
      for (final iso in _project!.isolines!)
        ..._isoToPolys(
          iso,
          _levelColor(iso.level ?? minL, minL, maxL),          // NEW
        ),
    ];
  }
  List<Polyline> _isoToPolys(IsolineDto iso, Color c) {
    final w = iso.geomWkt;
    if (w == null) return [];
    if (w.startsWith('LINESTRING')) {
      return [Polyline(points: _line(w), strokeWidth: 2.5, color: c)];
    } else if (w.startsWith('POLYGON')) {
      return [
        for (final ring in _polygon(w)) Polyline(points: ring, strokeWidth: 2.5, color: c),
      ];
    }
    return [];
  }

  void _onTap(TapPosition _, LatLng p) => setState(() {
    if (_start == null) {
      _start = p;
    } else {
      _end = p;
    }
  });

  void _clear() => setState(() {
    _start = null;
    _end = null;
  });

  void _fitBounds() {
    final b = _boundsFromPolygon(_project?.bboxWkt);
    if (b != null) _mapController.fitBounds(b);
  }

  Future<Uint8List> _captureMapImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final rrb = _mapKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio * 2;
    final img = await rrb.toImage(pixelRatio: dpr);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }

  Future<void> _submit() async {
    if (_start == null || _end == null) return;

    final sel = LatLngBounds(_start!, _end!);
    _mapController.fitBounds(sel, options: const FitBoundsOptions(padding: EdgeInsets.all(60)));
    await Future.delayed(const Duration(milliseconds: 300));

    final mapBytes = await _captureMapImage();

    final resp = await _api.createProfile(
      projectId: widget.projectId!,
      start: [_start!.longitude, _start!.latitude],
      end: [_end!.longitude, _end!.latitude],
    );

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/profileDetail',
      arguments: {
        'projectId': widget.projectId!,
        'profileId': resp.profileId ?? '',
        'mapBytes': mapBytes,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bounds = _boundsFromPolygon(_project?.bboxWkt);
    final isoPolys = _buildIsolines();

    final markers = [
      if (_start != null) _mk(_start!, Colors.blue),
      if (_end != null) _mk(_end!, Colors.red),
    ];

    final selLine = (_start != null && _end != null)
        ? Polyline(
      points: [_start!, _end!],
      strokeWidth: 4,
      color: Colors.blue.shade700,
      isDotted: true,
    )
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(_project?.name ?? 'Project'), actions: [
        IconButton(icon: const Icon(Icons.my_location), onPressed: _fitBounds)
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: RepaintBoundary(
                  key: _mapKey,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: bounds?.center,
                      zoom: _zoom,
                      bounds: bounds,
                      interactiveFlags: InteractiveFlag.all,
                      onTap: _onTap,
                      onMapReady: () => bounds != null ? _mapController.fitBounds(bounds) : null,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (isoPolys.isNotEmpty)
                        PolylineLayer(polylines: [
                          ...isoPolys,
                          if (selLine != null) selLine,
                        ]),
                      if (markers.isNotEmpty) MarkerLayer(markers: markers),
                    ],
                  ),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_start != null && _end != null) ? _submit : null,
                    icon: const Icon(Icons.terrain, size: 20),
                    label: const Text('PROFILE'),
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

  BottomNavigationBar _buildBottomNav() => BottomNavigationBar(
    currentIndex: 0,
    onTap: (i) {
      if (i == 0) Navigator.pop(context);
      if (i == 1) Navigator.pushNamed(context, '/profile');
      if (i == 2) Navigator.pushNamed(context, '/settings');
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
    ],
  );

  Marker _mk(LatLng p, Color c) => Marker(
    point: p,
    width: 24,
    height: 24,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
    ),
  );
}
