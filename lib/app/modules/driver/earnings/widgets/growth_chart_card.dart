import 'package:digaxy/app/modules/driver/earnings/controllers/earnings_controller.dart';
import 'package:digaxy/shared/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GrowthChartCard extends StatelessWidget {
  const GrowthChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EarningsController>()
        ? Get.find<EarningsController>()
        : Get.put(EarningsController());

    return Obx(() {
      final growthList = controller.yearlyGrowth;
      final summary = controller.yearlyGrowthSummary;
      final year = summary['year']?.toString() ??
          (growthList.isNotEmpty ? growthList.first['year']?.toString() : null) ??
          DateTime.now().year.toString();

      final List<Map<String, dynamic>> data = growthList.isNotEmpty
          ? growthList
          : _defaultEmptyMonths(int.tryParse(year) ?? DateTime.now().year);

      // Extract spots and compute max value
      final List<FlSpot> spots = [];
      double maxEarnings = 0.0;

      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        final rawVal = item['earnings'] ?? item['amount'];
        final val = rawVal is num
            ? rawVal.toDouble()
            : (double.tryParse(rawVal?.toString() ?? '') ?? 0.0);
        if (val > maxEarnings) {
          maxEarnings = val;
        }
        spots.add(FlSpot(i.toDouble(), val));
      }

      // Calculate dynamic maxY and horizontal interval
      final double maxY = _calculateMaxY(maxEarnings);
      final double horizontalInterval = (maxY / 4) > 0 ? (maxY / 4) : 25;

      return Container(
        width: double.infinity,
        height: 250.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Growth",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF092832),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$year (Monthly)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble().clamp(0, double.infinity),
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: horizontalInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final item = (index >= 0 && index < data.length)
                              ? data[index]
                              : null;
                          final monthTitle = item?['month_name'] ??
                              item?['month'] ??
                              'Month';
                          final deliveries = item?['total_deliveries'] ?? 0;
                          return LineTooltipItem(
                            '$monthTitle ($year)\nEarnings: \$${spot.y.toStringAsFixed(2)}\nDeliveries: $deliveries',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36.w,
                        interval: horizontalInterval,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > maxY) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _formatYAxis(value),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22.h,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final monthLabel =
                              (data[index]['month'] ?? '').toString();
                          return Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              monthLabel,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.35,
                      barWidth: 2.5,
                      color: AppColors.accent,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 2.5,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.accent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accent.withValues(alpha: 0.35),
                            AppColors.accent.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                      spots: spots,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  static double _calculateMaxY(double maxVal) {
    if (maxVal <= 0) return 100;
    if (maxVal <= 10) return 10;
    if (maxVal <= 50) return 50;
    if (maxVal <= 100) return 100;
    if (maxVal <= 500) return ((maxVal / 100).ceil() * 100).toDouble();
    if (maxVal <= 1000) return ((maxVal / 200).ceil() * 200).toDouble();
    if (maxVal <= 5000) return ((maxVal / 1000).ceil() * 1000).toDouble();
    return ((maxVal / 2000).ceil() * 2000).toDouble();
  }

  static String _formatYAxis(double value) {
    if (value >= 1000) {
      final kVal = value / 1000;
      return '\$${kVal % 1 == 0 ? kVal.toInt().toString() : kVal.toStringAsFixed(1)}k';
    }
    return '\$${value.toInt()}';
  }

  static List<Map<String, dynamic>> _defaultEmptyMonths(int year) {
    const months = [
      {'month': 'Jan', 'month_name': 'January', 'month_number': 1},
      {'month': 'Feb', 'month_name': 'February', 'month_number': 2},
      {'month': 'Mar', 'month_name': 'March', 'month_number': 3},
      {'month': 'Apr', 'month_name': 'April', 'month_number': 4},
      {'month': 'May', 'month_name': 'May', 'month_number': 5},
      {'month': 'Jun', 'month_name': 'June', 'month_number': 6},
      {'month': 'Jul', 'month_name': 'July', 'month_number': 7},
      {'month': 'Aug', 'month_name': 'August', 'month_number': 8},
      {'month': 'Sep', 'month_name': 'September', 'month_number': 9},
      {'month': 'Oct', 'month_name': 'October', 'month_number': 10},
      {'month': 'Nov', 'month_name': 'November', 'month_number': 11},
      {'month': 'Dec', 'month_name': 'December', 'month_number': 12},
    ];

    return months
        .map(
          (m) => {
            ...m,
            'year': year,
            'earnings': 0.0,
            'amount': 0.0,
            'total_deliveries': 0,
            'growth_percentage': 0.0,
          },
        )
        .toList();
  }
}
