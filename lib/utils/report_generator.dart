import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../api/api.swagger.dart';

class ReportGenerator {
  static Future<Uint8List> build({
    required Uint8List mapPng,
    required List<ProfilePoint> points,
    required Map<String, String> metrics,
  }) async {
    const hScale = 5000;
    const vScale = 500;
    const innerWmm = 180.0;

    await initializeDateFormatting('ru_RU');
    final fontR = pw.Font.ttf(
        await rootBundle.load('lib/assets/fonts/Roboto-Regular.ttf'));
    final fontB =
    pw.Font.ttf(await rootBundle.load('lib/assets/fonts/Roboto-Bold.ttf'));

    final hd = pw.TextStyle(font: fontB, fontSize: 20, color: PdfColors.blue800);
    final ttl = pw.TextStyle(font: fontB, fontSize: 13);
    final txt = pw.TextStyle(font: fontR, fontSize: 11);
    final small = pw.TextStyle(font: fontR, fontSize: 9);
    final foot = pw.TextStyle(font: fontR, fontSize: 9, color: PdfColors.grey600);
    final accent = pw.TextStyle(font: fontB, fontSize: 11, color: PdfColors.blue800);

    /* ───── Изображения ───── */
    final mapImg = pw.MemoryImage(mapPng);

    /* ───── Данные графика ───── */
    // Фильтрация точек с null-значениями
    points = points.where((p) => p.distance != null && p.elevation != null).toList();

    if (points.isEmpty) {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Text('Ошибка: нет данных для построения профиля', style: hd),
          ),
        ),
      );
      return doc.save();
    }

    final minDist = points.first.distance!;
    final distKm = [for (var p in points) (p.distance! - minDist) / 1000];
    final elevs = [for (var p in points) p.elevation!.toDouble()];
    final minElev = elevs.reduce(math.min);
    final maxElev = elevs.reduce(math.max);
    final peakIdx = elevs.indexOf(maxElev);

    pw.FixedAxis _axisY() {
      final step = ((maxElev - minElev) / 4).roundToDouble();
      final ticks = [
        minElev,
        minElev + step,
        minElev + 2 * step,
        minElev + 3 * step,
        minElev + 4 * step,
      ];
      return pw.FixedAxis(
        ticks,
        format: (v) => v.toInt().toString(),
        textStyle: small.copyWith(font: fontB),
        divisions: true,
        divisionsColor: PdfColors.grey300,
      );
    }

    pw.FixedAxis _axisX() {
      final max = distKm.last;
      final ticks = [0, max / 4, max / 2, max * 3 / 4, max];
      return pw.FixedAxis(
        ticks,
        format: (v) => v.toStringAsFixed(1),
        textStyle: small.copyWith(font: fontB),
        divisions: true,
        divisionsColor: PdfColors.grey300,
      );
    }

    final verts = [
      for (int i = 0; i < points.length; i++)
        if (points[i].isOnIsoline == true)
          pw.LineDataSet(
            lineColor: PdfColors.grey400,
            lineWidth: .4,
            drawPoints: false,
            data: [
              pw.PointChartValue(distKm[i], minElev),
              pw.PointChartValue(distKm[i], elevs[i]),
            ],
          ),
    ];

    final profile = pw.LineDataSet(
      lineColor: PdfColors.black,
      lineWidth: 1.8,
      isCurved: true,
      drawPoints: false,
      data: [
        for (int i = 0; i < points.length; i++)
          pw.PointChartValue(distKm[i], elevs[i]),
      ],
    );

    final blackDots = pw.LineDataSet(
      lineColor: PdfColors.white,
      lineWidth: 0,
      drawPoints: true,
      pointSize: 3.5,
      pointColor: PdfColors.black,
      data: [
        pw.PointChartValue(distKm.first, elevs.first),
        if (peakIdx >= 0 && peakIdx < distKm.length)
          pw.PointChartValue(distKm[peakIdx], elevs[peakIdx]),
        pw.PointChartValue(distKm.last, elevs.last),
      ],
    );

    final orangeDots = pw.LineDataSet(
      lineColor: PdfColors.white,
      lineWidth: 0,
      drawPoints: true,
      pointSize: 3.5,
      pointColor: PdfColors.orange,
      data: [
        for (int i = 0; i < points.length; i++)
          if (points[i].isOnIsoline == true)
            pw.PointChartValue(distKm[i], elevs[i]),
      ],
    );

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => pw.Stack(
          children: [
            // Номер страницы
            pw.Positioned(
              bottom: 0,
              right: 0,
              child: pw.Text('1', style: foot),
            ),

            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('ТОПОГРАФИЧЕСКИЙ ПРОФИЛЬ РЕЛЬЕФА', style: hd),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        DateFormat('d MMMM y', 'ru_RU').format(DateTime.now()),
                        style: txt.copyWith(color: PdfColors.grey700),
                      ),
                      pw.Divider(height: 24, thickness: 1),
                    ],
                  ),
                ),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Схема маршрута', style: ttl),
                    pw.Spacer(),
                    pw.Text(
                      'Масштаб 1:$hScale',
                      style: small.copyWith(color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(mapImg, fit: pw.BoxFit.cover),
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Профиль рельефа\n',
                        style: accent,
                      ),
                      pw.TextSpan(
                        text: '• Горизонтальный: 1:$hScale\n',
                        style: txt,
                      ),
                      pw.TextSpan(
                        text: '• Вертикальный: 1:$vScale\n',
                        style: txt,
                      ),
                      pw.TextSpan(
                        text: '• Горизонтали проведены каждые 10 метров',
                        style: small.copyWith(color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Профиль рельефа\n', style: ttl),
                    pw.Spacer(),
                    pw.Text(
                      'Масштаб 1:$vScale',
                      style: small.copyWith(color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: points.isNotEmpty
                      ? pw.Chart(
                    grid: pw.CartesianGrid(
                      xAxis: _axisX(),
                      yAxis: _axisY(),
                    ),
                    datasets: [
                      ...verts,
                      profile,
                      orangeDots,
                      blackDots,
                    ],
                  )
                      : pw.Center(
                    child: pw.Text('Данные профиля недоступны', style: ttl),
                  ),
                ),
                pw.SizedBox(height: 10),
                points.isNotEmpty
                    ? pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Н: ${minElev.toInt()} м', style: small),
                    pw.Text('${distKm.last.toStringAsFixed(1)} км', style: small),
                  ],
                )
                    : pw.SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Stack(
          children: [
            pw.Positioned(
              bottom: 0,
              right: 0,
              child: pw.Text('2', style: foot),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Заголовок
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'ТЕХНИЧЕСКИЕ ХАРАКТЕРИСТИКИ',
                        style: ttl.copyWith(
                          fontSize: 16,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        DateFormat('d MMMM y', 'ru_RU').format(DateTime.now()),
                        style: txt.copyWith(color: PdfColors.grey700),
                      ),
                      pw.Divider(height: 24, thickness: 1),
                    ],
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.2),
                    1: pw.FlexColumnWidth(1.2),
                  },
                  children: [
                    // Заголовки столбцов
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: pw.Text('Параметр', style: ttl),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: pw.Text('Значение', style: ttl),
                        ),
                      ],
                    ),

                    for (int i = 0; i < metrics.length; i++)
                      pw.TableRow(
                        decoration: i.isEven
                            ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8FAFF))
                            : null,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            child: pw.Text(metrics.keys.elementAt(i), style: txt),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            child: pw.Text(
                              metrics.values.elementAt(i),
                              style: txt.copyWith(font: fontB),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    '© GeoProfiles ${DateTime.now().year}',
                    style: foot.copyWith(color: PdfColors.blue800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }
}