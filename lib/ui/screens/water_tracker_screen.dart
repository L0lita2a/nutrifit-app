import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({Key? key}) : super(key: key);

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
              _buildMainCard(context, state),
              const SizedBox(height: 24),
              _buildWaterGlasses(context, state),
              const SizedBox(height: 32),
              Text(
                'Quick Add',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickAddRow(context),
              const SizedBox(height: 32),
              Text(
                'Today\'s Log',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              state.waterConsumed == 0 ? _buildEmptyState(context) : _buildLogsList(context, state),
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
          'Water Tracker',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daily goal: ${state.dailyWaterGoal}ml',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 24.0,
              animation: true,
              animateFromLastPercent: true,
              percent: state.waterProgress,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: AppColors.primary,
              backgroundColor: AppColors.background,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.waterConsumed}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 48,
                        ),
                  ),
                  Text(
                    'ml consumed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(context, '${state.waterConsumed}ml', 'Consumed', AppColors.blueAccent),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _buildStatColumn(context, '${state.dailyWaterGoal - state.waterConsumed > 0 ? state.dailyWaterGoal - state.waterConsumed : 0}ml', 'Remaining', AppColors.textDark),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _buildStatColumn(context, '${(state.waterProgress * 100).toInt()}%', 'Complete', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
      ],
    );
  }

  Widget _buildWaterGlasses(BuildContext context, AppState state) {
    int fullGlasses = (state.waterConsumed / 250).floor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(8, (index) {
        bool isFull = index < fullGlasses;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isFull ? AppColors.blueAccent : Colors.transparent,
            border: Border.all(color: isFull ? AppColors.blueAccent : AppColors.orangeAccent.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isFull ? Icons.water_drop : Icons.water_drop_outlined,
            color: isFull ? Colors.white : AppColors.orangeAccent.withOpacity(0.3),
            size: 24,
          ),
        );
      }),
    );
  }

  Widget _buildQuickAddRow(BuildContext context) {
    final amounts = ['150ml', '250ml', '350ml', '500ml'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: amounts.map((amount) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                int val = int.parse(amount.replaceAll('ml', ''));
                Provider.of<AppState>(context, listen: false).addWater(val);
              },
              icon: const Icon(Icons.water_drop_outlined, size: 18),
              label: Text(amount),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueAccent,
                side: const BorderSide(color: AppColors.blueLight, width: 2),
                backgroundColor: AppColors.blueLight.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No water logged yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context, AppState state) {
    return ListTile(
      leading: const Icon(Icons.water_drop, color: AppColors.blueAccent),
      title: const Text('Total Water Consumed', style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text('${state.waterConsumed} ml', style: const TextStyle(color: AppColors.textLight)),
      contentPadding: EdgeInsets.zero,
    );
  }
}
