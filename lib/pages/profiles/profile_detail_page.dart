
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';
import '../../utils/report_generator.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({
    Key? key,
    required this.projectId,
    required this.profileId,
    this.mapBytes,
  }) : super(key: key);

  final String projectId;
  final String profileId;
  final Uint8List? mapBytes;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late final ApiService _api;
  FullProfileResponse? _profile;
  bool _loading = true;
  bool _loadingReport = false;

  final _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final prof = await _api.getFullProfile(
        projectId: widget.projectId,
        profileId: widget.profileId,
      );
      if (!mounted) return;
      setState(() => _profile = prof);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  List<ProfilePoint> dedupIsolines(List<ProfilePoint> src, {int n = 2}) {
    final res = List<ProfilePoint>.from(src);
    final len = res.length;
    int i = 0;
    while (i < len) {
      if (res[i].isOnIsoline != true) {
        i++;
        continue;
      }
      final l = math.max(0, i - n);
      final r = math.min(len - 1, i + n);

      final isoIdx = <int>[];
      for (int k = l; k <= r; k++) {
        if (res[k].isOnIsoline == true) isoIdx.add(k);
      }
      if (isoIdx.length > 1) {
        final keep = isoIdx[isoIdx.length ~/ 2];
        for (final k in isoIdx) {
          if (k == keep) continue;
          res[k] = res[k].copyWith(isOnIsoline: false);
        }
      }
      i = r + 1;
    }
    return res;
  }


  double _ascent(List<ProfilePoint> pts) => pts.skip(1).fold<double>(
      0,
          (s, p) =>
      s + math.max(0, p.elevation! - pts[pts.indexOf(p) - 1].elevation!));

  double _descent(List<ProfilePoint> pts) => pts.skip(1).fold<double>(
      0,
          (s, p) =>
      s + math.max(0, pts[pts.indexOf(p) - 1].elevation! - p.elevation!));

  double _maxSlope(List<ProfilePoint> pts) {
    double m = 0;
    for (int i = 1; i < pts.length; i++) {
      final dy = (pts[i].elevation! - pts[i - 1].elevation!).abs();
      final dx = pts[i].distance! - pts[i - 1].distance!;
      if (dx != 0) m = math.max(m, dy / dx);
    }
    return m;
  }

  double _avgSlope(List<ProfilePoint> pts, bool up) {
    double s = 0;
    int c = 0;
    for (int i = 1; i < pts.length; i++) {
      final dy = pts[i].elevation! - pts[i - 1].elevation!;
      final dx = pts[i].distance! - pts[i - 1].distance!;
      if (dx == 0) continue;
      if (up && dy > 0) {
        s += dy / dx;
        c++;
      } else if (!up && dy < 0) {
        s += dy.abs() / dx;
        c++;
      }
    }
    return c == 0 ? 0 : s / c;
  }

  double _range(List<ProfilePoint> pts) =>
      pts.map((e) => e.elevation!).reduce(math.max) -
          pts.map((e) => e.elevation!).reduce(math.min);

  int _peak(List<ProfilePoint> pts) => pts.indexWhere(
          (p) => p.elevation == pts.map((e) => e.elevation!).reduce(math.max));

  Map<String, String> _metricsRu(List<ProfilePoint> pts) {
    return {
      'Минимальная высота':
      '${pts.map((e) => e.elevation!).reduce(math.min).round()} м',
      'Максимальная высота':
      '${pts.map((e) => e.elevation!).reduce(math.max).round()} м',
      'Длина маршрута':
      '${((_profile!.lengthM ?? 0) / 1000).toStringAsFixed(1)} км',
      'Набор высоты': '${_ascent(pts).round()} м',
      'Потеря высоты': '${_descent(pts).round()} м',
      'Максимальный уклон': '${(_maxSlope(pts) * 100).toStringAsFixed(1)} %',
      'Средний уклон подъёма':
      '${(_avgSlope(pts, true) * 100).toStringAsFixed(1)} %',
      'Средний уклон спуска':
      '${(_avgSlope(pts, false) * 100).toStringAsFixed(1)} %',
      'Перепад высот': '${_range(pts).round()} м',
    };
  }


  Future<Uint8List> _captureChart() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
    _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final dpr =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio * 3;
    final img = await boundary.toImage(pixelRatio: dpr);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> _buildPdf(_PdfArgs a) =>
      ReportGenerator.build(mapPng: a.map, points: a.points, metrics: a.metrics);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _BottomNav(selectedIndex: 1),
      );
    }

    if (_profile?.points == null || _profile!.points!.length < 2) {
      return const Scaffold(
        body: Center(child: Text('No profile data')),
        bottomNavigationBar: _BottomNav(selectedIndex: 1),
      );
    }

    final pts = dedupIsolines(_profile!.points!, n: 2);

    final minElev = pts.map((p) => p.elevation!).reduce(math.min);
    final maxElev = pts.map((p) => p.elevation!).reduce(math.max);
    final peakIndex = _peak(pts);

    final minDist = pts.first.distance!;
    final maxDist = pts.last.distance!;

    final profileSpots =
    pts.map((p) => FlSpot(p.distance! - minDist, p.elevation!)).toList();

    final verticalBars = [
      for (final p in pts)
        if (p.isOnIsoline == true)
          LineChartBarData(
            spots: [
              FlSpot(p.distance! - minDist, minElev.toDouble()),
              FlSpot(p.distance! - minDist, p.elevation! - 0.1),
            ],
            isCurved: false,
            color: Colors.black,
            barWidth: 1,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
    ];

    final xInterval = (maxDist - minDist) / 5;
    final yInterval = (maxElev - minElev) / 5;

    final ascent = _ascent(pts).round();
    final descent = _descent(pts).round();
    final maxSlope = _maxSlope(pts);
    final avgAscSlope = _avgSlope(pts, true);
    final avgDescSlope = _avgSlope(pts, false);
    final elevationRange = _range(pts).round();
    final lengthKm = (_profile!.lengthM ?? 0) / 1000;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const _BottomNav(selectedIndex: 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Elevation',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: _chartKey,
              child: SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    clipData: FlClipData.all(),
                    minX: 0,
                    maxX: maxDist - minDist,
                    minY: minElev,
                    maxY: maxElev + 20,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: yInterval,
                      verticalInterval: xInterval,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                      getDrawingVerticalLine: (_) =>
                          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        axisNameWidget: const Text('Высота, м',
                            style: TextStyle(fontSize: 12)),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: yInterval,
                          reservedSize: 42,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: const Text('Расстояние, км',
                            style: TextStyle(fontSize: 12)),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: xInterval,
                          reservedSize: 28,
                          getTitlesWidget: (v, _) => Text(
                              '${(v / 1000).toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade400)),
                    lineTouchData: LineTouchData(),
                    lineBarsData: [
                      ...verticalBars,
                      LineChartBarData(
                        spots: profileSpots,
                        isCurved: true,
                        color: Colors.black,
                        barWidth: 3,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, i) {
                            final point = pts[i];
                            if (point.isOnIsoline == true) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.orange,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            }
                            if (i == 0 ||
                                i == peakIndex ||
                                i == pts.length - 1) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.black,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            }
                            return FlDotCirclePainter(
                                radius: 0, color: Colors.transparent);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildReportButton(pts),
            const SizedBox(height: 24),
            _buildMetricCard(
              icon: Icons.terrain,
              title: 'Min Elevation',
              value: '${minElev.round()} m',
              description: 'Минимальная высота маршрута',
            ),
            _buildMetricCard(
              icon: Icons.landscape,
              title: 'Max Elevation',
              value: '${maxElev.round()} m',
              description: 'Максимальная высота маршрута',
            ),
            _buildMetricCard(
              icon: Icons.straighten,
              title: 'Length',
              value: '${NumberFormat('#,##0.0', 'en').format(lengthKm)} km',
              description: 'Общая протяжённость маршрута',
            ),
            _buildMetricCard(
              icon: Icons.trending_up,
              title: 'Total Ascent',
              value: '$ascent m',
              description: 'Суммарный подъём',
            ),
            _buildMetricCard(
              icon: Icons.trending_down,
              title: 'Total Descent',
              value: '$descent m',
              description: 'Суммарный спуск',
            ),
            _buildMetricCard(
              icon: Icons.warning,
              title: 'Max Slope',
              value: '${(maxSlope * 100).toStringAsFixed(1)} %',
              description: 'Самый крутой уклон',
            ),
            _buildMetricCard(
              icon: Icons.arrow_upward,
              title: 'Avg Ascent Slope',
              value: '${(avgAscSlope * 100).toStringAsFixed(1)} %',
              description: 'Средний уклон подъёма',
            ),
            _buildMetricCard(
              icon: Icons.arrow_downward,
              title: 'Avg Descent Slope',
              value: '${(avgDescSlope * 100).toStringAsFixed(1)} %',
              description: 'Средний уклон спуска',
            ),
            _buildMetricCard(
              icon: Icons.height,
              title: 'Elevation Range',
              value: '$elevationRange m',
              description: 'Перепад высот',
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildReportButton(List<ProfilePoint> ptsFiltered) {
    return ElevatedButton.icon(
      icon: _loadingReport
          ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.picture_as_pdf),
      label: Text(_loadingReport ? 'Формируем PDF-отчёт' : 'Сформировать PDF-отчёт'),
      onPressed: _loadingReport
          ? null
          : () async {
        setState(() => _loadingReport = true);
        try {
          await _api.getProfileReport(
            projectId: widget.projectId,
            profileId: widget.profileId,
          );

          final chartPng = await _captureChart();
          final mapPng = widget.mapBytes!;

          final pdfBytes = await compute(
            _buildPdf,
            _PdfArgs(mapPng, ptsFiltered, _metricsRu(ptsFiltered)),
          );

          await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось сформировать отчёт: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _loadingReport = false);
        }
      },
    );
  }


  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20),
              color: Colors.grey,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(title),
                    content: Text(description),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _PdfArgs {
  final Uint8List map;
  final List<ProfilePoint> points;
  final Map<String, String> metrics;
  _PdfArgs(this.map, this.points, this.metrics);
}


class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: (i) {
      switch (i) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(
              context, '/projects', (_) => false);
          break;
        case 1:
          Navigator.pop(context);
          break;
        case 2:
          Navigator.pushNamed(context, '/settings');
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), label: 'Profile'),
      BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined), label: 'Settings'),
    ],
  );
}
