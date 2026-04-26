import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Strength', 'Cardio', 'Flexibility', 'Other'];

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
              const SizedBox(height: 24),
              _buildStatsRow(context, state),
              const SizedBox(height: 24),
              _buildCategoryTabs(),
              const SizedBox(height: 32),
              Text(
                'Quick Add',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickAddList(context),
              const SizedBox(height: 48),
              state.workoutLogs.isEmpty ? _buildEmptyState(context) : _buildLogsList(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${state.workoutLogs.length} exercises • ${state.workoutMinutes} min',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.purpleAccent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(context, Icons.fitness_center, '${state.workoutLogs.length}', 'Exercises', AppColors.purpleLight, AppColors.purpleAccent),
        _buildStatCard(context, Icons.schedule, '${state.workoutMinutes}', 'Minutes', AppColors.blueLight, AppColors.blueAccent),
        _buildStatCard(context, Icons.monitor_weight_outlined, '0', 'Volume', AppColors.orangeLight, AppColors.orangeAccent),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color bgColor, Color iconColor) {
    return Expanded(
      child: Card(
        color: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickAddList(BuildContext context) {
    final items = [
      {'name': 'Push-ups', 'mins': '10', 'icon': Icons.fitness_center, 'color': AppColors.purpleAccent},
      {'name': 'Running', 'mins': '30', 'icon': Icons.directions_run, 'color': AppColors.orangeAccent},
      {'name': 'Squats', 'mins': '20', 'icon': Icons.fitness_center, 'color': AppColors.purpleAccent},
      {'name': 'Plank', 'mins': '5', 'icon': Icons.accessibility_new, 'color': AppColors.greenAccent},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: items.map((item) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Provider.of<AppState>(context, listen: false).addWorkout(
                    item['name'] as String,
                    int.parse(item['mins'] as String),
                    _selectedCategory,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                  child: Column(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['mins']} min',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
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
            Icons.fitness_center,
            size: 64,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts logged today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Log',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        for (var log in state.workoutLogs)
          ListTile(
            leading: const Icon(Icons.fitness_center, color: AppColors.purpleAccent),
            title: Text(log.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(log.category),
            trailing: Text('${log.minutes} min', style: const TextStyle(color: AppColors.textLight)),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
