import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

class ProfileDetailPage extends StatefulWidget {
  final String projectId;
  final String profileId;
  const ProfileDetailPage({super.key, required this.projectId, required this.profileId});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late final ApiService _api;
  FullProfileResponse? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiService>();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final result = await _api.getFullProfile(
        projectId: widget.projectId,
        profileId: widget.profileId,
      );
      if (mounted) setState(() => _data = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _ascent(List<ProfilePoint> pts) {
    double total = 0;
    for (var i = 1; i < pts.length; i++) {
      final diff = pts[i].elevation! - pts[i - 1].elevation!;
      if (diff > 0) total += diff;
    }
    return total;
  }

  double _descent(List<ProfilePoint> pts) {
    double total = 0;
    for (var i = 1; i < pts.length; i++) {
      final diff = pts[i - 1].elevation! - pts[i].elevation!;
      if (diff > 0) total += diff;
    }
    return total;
  }

  double _maxSlope(List<ProfilePoint> pts) {
    double maxSlope = 0;
    for (var i = 1; i < pts.length; i++) {
      final dy = pts[i].elevation! - pts[i - 1].elevation!;
      final dx = pts[i].distance! - pts[i - 1].distance!;
      if (dx != 0) {
        final slope = dy.abs() / dx;
        if (slope > maxSlope) maxSlope = slope;
      }
    }
    return maxSlope;
  }

  double _avgAscentSlope(List<ProfilePoint> pts) {
    double total = 0;
    int count = 0;
    for (var i = 1; i < pts.length; i++) {
      final dy = pts[i].elevation! - pts[i - 1].elevation!;
      final dx = pts[i].distance! - pts[i - 1].distance!;
      if (dx != 0 && dy > 0) {
        total += dy / dx;
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  double _avgDescentSlope(List<ProfilePoint> pts) {
    double total = 0;
    int count = 0;
    for (var i = 1; i < pts.length; i++) {
      final dy = pts[i - 1].elevation! - pts[i].elevation!;
      final dx = pts[i].distance! - pts[i - 1].distance!;
      if (dx != 0 && dy > 0) {
        total += dy / dx;
        count++;
      }
    }
    return count > 0 ? total / count : 0;
  }

  double _elevationRange(List<ProfilePoint> pts) {
    final min = pts.map((p) => p.elevation!).reduce(math.min);
    final max = pts.map((p) => p.elevation!).reduce(math.max);
    return max - min;
  }

  int _peakPointIndex(List<ProfilePoint> pts) {
    double maxElev = double.negativeInfinity;
    int index = 0;
    for (int i = 0; i < pts.length; i++) {
      if (pts[i].elevation! > maxElev) {
        maxElev = pts[i].elevation!;
        index = i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_data == null || _data!.points == null || _data!.points!.length < 2) {
      return const Scaffold(
        body: Center(child: Text('No profile data')),
      );
    }

    final pts = _data!.points!;
    final minElev = pts.map((p) => p.elevation!).reduce(math.min);
    final maxElev = pts.map((p) => p.elevation!).reduce(math.max);
    final ascent = _ascent(pts).round();
    final descent = _descent(pts).round();
    final maxSlope = _maxSlope(pts);
    final avgAscentSlope = _avgAscentSlope(pts);
    final avgDescentSlope = _avgDescentSlope(pts);
    final elevationRange = _elevationRange(pts).round();
    final peakIndex = _peakPointIndex(pts);
    final lengthKm = (_data!.lengthM ?? 0) / 1000;

    final minDist = pts.first.distance!;
    final maxDist = pts.last.distance!;

    final adjustedSpots = pts
        .map((p) => FlSpot(
      p.distance! - minDist,
      p.elevation! < 0 ? 0 : p.elevation!,
    ))
        .toList();

    final rawX = (maxDist - minDist) / 5;
    final xInterval = rawX > 0 ? rawX : 1.0;
    final rawY = (maxElev - minElev) / 5;
    final yInterval = rawY > 0 ? rawY : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const _BottomNav(selectedIndex: 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Elevation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxDist - minDist,
                  minY: 0,
                  maxY: (maxElev < 0 ? 0 : maxElev).toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: yInterval,
                    verticalInterval: xInterval,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval,
                        reservedSize: 40,
                        getTitlesWidget: (val, _) =>
                            Text(val.toInt().toString(),
                                style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: xInterval,
                        getTitlesWidget: (val, _) => Text(
                            (val / 1000).toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: adjustedSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (index == 0 ||
                              index == adjustedSpots.length - 1 ||
                              index == peakIndex) {
                            return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white
                            );
                          }
                          return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildMetricCard(
              icon: Icons.terrain,
              title: 'Min Elevation',
              value: '${minElev < 0 ? 0 : minElev.toInt()} m',
              description: 'Минимальная высота над уровнем моря на маршруте',
            ),
            _buildMetricCard(
              icon: Icons.landscape,
              title: 'Max Elevation',
              value: '${maxElev < 0 ? 0 : maxElev.toInt()} m',
              description: 'Максимальная высота над уровнем моря на маршруте',
            ),
            _buildMetricCard(
              icon: Icons.straighten,
              title: 'Length',
              value: '${NumberFormat('#,##0.0', 'en').format(lengthKm)} km',
              description: 'Общая протяженность маршрута',
            ),
            _buildMetricCard(
              icon: Icons.trending_up,
              title: 'Total Ascent',
              value: '$ascent m',
              description: 'Суммарный набор высоты на всех подъемах маршрута',
            ),
            _buildMetricCard(
              icon: Icons.trending_down,
              title: 'Total Descent',
              value: '$descent m',
              description: 'Суммарная потеря высоты на всех спусках маршрута',
            ),
            _buildMetricCard(
              icon: Icons.warning,
              title: 'Max Slope',
              value: '${(maxSlope * 100).toStringAsFixed(1)}%',
              description: 'Максимальный уклон на маршруте (самый крутой участок)',
            ),
            _buildMetricCard(
              icon: Icons.arrow_upward,
              title: 'Avg Ascent Slope',
              value: '${(avgAscentSlope * 100).toStringAsFixed(1)}%',
              description: 'Средний уклон на участках подъема',
            ),
            _buildMetricCard(
              icon: Icons.arrow_downward,
              title: 'Avg Descent Slope',
              value: '${(avgDescentSlope * 100).toStringAsFixed(1)}%',
              description: 'Средний уклон на участках спуска',
            ),
            _buildMetricCard(
              icon: Icons.height,
              title: 'Elevation Range',
              value: '$elevationRange m',
              description: 'Перепад высот между самой низкой и самой высокой точками',
            ),
          ],
        ),
      ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20),
              color: Colors.grey,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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

class _BottomNav extends StatelessWidget {
  final int selectedIndex;

  const _BottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) =>
      BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/projects', (route) => false);
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
              icon: Icon(Icons.settings_outlined),
              label: 'Settings'),
        ],
      );
}