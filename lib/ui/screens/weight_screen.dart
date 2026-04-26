import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 32),
              _buildChartCard(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight Progress',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Current: ${state.weight} kg',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, AppState state) {
    if (state.weightLogs.isEmpty) {
      return const Center(child: Text("No weight data"));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: AppColors.textLight, fontSize: 12);
                      if (value % 2 != 0) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text('D${value.toInt()}', style: style),
                      );
                    },
                    reservedSize: 32,
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}kg', style: const TextStyle(color: AppColors.textLight, fontSize: 12));
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (state.weightLogs.length - 1).toDouble(),
              minY: state.weightLogs.reduce((a, b) => a < b ? a : b) - 2,
              maxY: state.weightLogs.reduce((a, b) => a > b ? a : b) + 2,
              lineBarsData: [
                LineChartBarData(
                  spots: state.weightLogs.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: AppColors.pinkAccent,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.pinkLight.withOpacity(0.5),
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
