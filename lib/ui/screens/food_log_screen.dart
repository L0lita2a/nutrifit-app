import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({Key? key}) : super(key: key);

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];

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
              state.foodLogs.isEmpty ? _buildEmptyState(context) : _buildLogsList(state),
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
              'Food Log',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: '${state.caloriesConsumed} / ${state.dailyCalorieGoal} kcal • '),
                  TextSpan(
                    text: '${state.caloriesRemaining > 0 ? state.caloriesRemaining : 0} left',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
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
      {'name': 'Oatmeal', 'cals': '150', 'icon': Icons.wb_twilight, 'color': AppColors.orangeAccent},
      {'name': 'Chicken Breast', 'cals': '165', 'icon': Icons.wb_sunny_outlined, 'color': AppColors.orangeAccent},
      {'name': 'Brown Rice', 'cals': '216', 'icon': Icons.wb_sunny_outlined, 'color': AppColors.orangeAccent},
      {'name': 'Banana', 'cals': '89', 'icon': Icons.coffee_outlined, 'color': AppColors.orangeAccent},
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
                  Provider.of<AppState>(context, listen: false).addFood(
                    item['name'] as String,
                    int.parse(item['cals'] as String),
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
                        '${item['cals']} kcal',
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
            Icons.coffee_outlined,
            size: 64,
            color: AppColors.orangeAccent.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No food logged yet today',
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
        for (var log in state.foodLogs)
          ListTile(
            leading: const Icon(Icons.check_circle, color: AppColors.primary),
            title: Text(log.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(log.category),
            trailing: Text('${log.calories} kcal', style: const TextStyle(color: AppColors.textLight)),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}
