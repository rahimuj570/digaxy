import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GrowthChartCard extends StatelessWidget {
  const GrowthChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Growth",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: const [
                  Text(
                    "Monthly",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}k",
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "July", "Agu"];
                        if (value < 0 || value > 7) return Container();
                        return Text(
                          months[value.toInt()],
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 2,
                    color: Colors.orange.shade300,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    dashArray: [4, 4], // dotted line
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.shade200.withAlpha(102),
                          Colors.orange.shade200.withAlpha(13),
                        ],
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 10),
                      FlSpot(1, 20),
                      FlSpot(2, 40),
                      FlSpot(3, 55),
                      FlSpot(4, 12),
                      FlSpot(5, 25),
                      FlSpot(6, 60),
                      FlSpot(7, 75),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
