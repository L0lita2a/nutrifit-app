import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight Progress (Last 7 Days)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildWeightChart(state.weightLogs),
              const SizedBox(height: 48),
              Text(
                'Calorie Consumption vs Target',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildCaloriesChart(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<double> weightLogs) {
    if (weightLogs.isEmpty) {
      return const Center(child: Text('No weight data available.'));
    }

    double minWeight = weightLogs.reduce((curr, next) => curr < next ? curr : next);
    double maxWeight = weightLogs.reduce((curr, next) => curr > next ? curr : next);
    
    List<FlSpot> spots = [];
    for (int i = 0; i < weightLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), weightLogs[i]));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()} kg', style: const TextStyle(fontSize: 10, color: Colors.grey));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (weightLogs.length - 1).toDouble(),
            minY: (minWeight - 2).floorToDouble(),
            maxY: (maxWeight + 2).ceilToDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(AppState state) {
    List<BarChartGroupData> barGroups = [];
    int maxDays = 5;
    
    for (int i = 0; i < maxDays - 1; i++) {
      int randomCalories = 1800 + (i * 100);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: randomCalories.toDouble(),
              color: randomCalories <= state.dailyCalorieGoal ? AppColors.primary : Colors.orangeAccent,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    
    barGroups.add(
      BarChartGroupData(
        x: maxDays - 1,
        barRods: [
          BarChartRodData(
            toY: state.caloriesConsumed.toDouble(),
            color: state.caloriesConsumed <= state.dailyCalorieGoal ? AppColors.primary : Colors.redAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );

    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (state.dailyCalorieGoal * 1.5).toDouble(),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    Widget textWidget;
                    if (value.toInt() == maxDays - 1) {
                      textWidget = const Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                    } else {
                      textWidget = Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: textWidget,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value % 500 == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 500,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: state.dailyCalorieGoal.toDouble(),
                  color: Colors.redAccent.withOpacity(0.5),
                  strokeWidth: 2,
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    style: const TextStyle(fontSize: 10, color: Colors.redAccent),
                    labelResolver: (line) => 'Target',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
