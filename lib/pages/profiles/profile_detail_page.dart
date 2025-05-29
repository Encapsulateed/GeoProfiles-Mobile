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

  // Calculate total ascent
  double _ascent(List<ProfilePoint> pts) {
    double total = 0;
    for (var i = 1; i < pts.length; i++) {
      final diff = pts[i].elevation! - pts[i - 1].elevation!;
      if (diff > 0) total += diff;
    }
    return total;
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
    final lengthKm = (_data!.lengthM ?? 0) / 1000;

    final minDist = pts.first.distance!;
    final maxDist = pts.last.distance!;
    final spots = pts
        .map((p) => FlSpot(p.distance! - minDist, p.elevation!))
        .toList();

    // Compute intervals, ensure non-zero
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
                  minY: minElev.toDouble(),
                  maxY: maxElev.toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) => FlLine(
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
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.black,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _metric('Min Elevation', '${minElev.toInt()} m'),
                _metric('Length',
                    '${NumberFormat('#,##0.0', 'en').format(lengthKm)} km'),
                _metric('Total Ascent', '${ascent} m'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () {/* TODO share */},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Share',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 4),
      Text(value,
          style:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );
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
