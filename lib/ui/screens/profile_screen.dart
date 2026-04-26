import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _waterReminder = true;
  bool _workoutReminder = true;

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
              Text(
                'Daily Goals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildDailyGoalsCard(context, state),
              const SizedBox(height: 32),
              Text(
                'All Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildAllTimeStats(context, state),
              const SizedBox(height: 32),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildAchievements(state),
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
        Text(
          'Profile',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
              ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _showAvatarPicker(context),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: Text(state.avatar, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                Provider.of<AppState>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyGoalsCard(BuildContext context, AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.bolt, color: AppColors.orangeAccent),
              title: const Text('Calories'),
              trailing: Text('${state.dailyCalorieGoal} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.water_drop, color: AppColors.blueAccent),
              title: const Text('Water'),
              trailing: Text('${state.dailyWaterGoal} ml', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            const ListTile(
              leading: Icon(Icons.show_chart, color: AppColors.purpleAccent),
              title: Text('Activity'),
              trailing: Text('Moderate', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeStats(BuildContext context, AppState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatBox(context, Icons.restaurant, state.foodLogs.length.toString(), 'Food Logs', AppColors.orangeLight, AppColors.orangeAccent),
        _buildStatBox(context, Icons.fitness_center, state.workoutLogs.length.toString(), 'Workouts', AppColors.purpleLight, AppColors.purpleAccent),
        _buildStatBox(context, Icons.water_drop, (state.waterConsumed > 0 ? 1 : 0).toString(), 'Water Logs', AppColors.blueLight, AppColors.blueAccent),
        _buildStatBox(context, Icons.show_chart, state.weightLogs.length.toString(), 'Weight Logs', AppColors.pinkLight, AppColors.pinkAccent),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, IconData icon, String value, String label, Color bgColor, Color iconColor) {
    return Card(
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textDark,
                  fontSize: 32,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(AppState state) {
    bool hydrationHero = state.waterProgress >= 1.0;
    bool streakStarter = state.currentStreak >= 3;
    bool streakMaster = state.currentStreak >= 7;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildBadge(
            icon: '💧',
            title: 'Hydration Hero',
            description: 'Hit water goal today',
            isUnlocked: hydrationHero,
          ),
          const SizedBox(width: 16),
          _buildBadge(
            icon: '🔥',
            title: 'Streak Starter',
            description: '3-day logging streak',
            isUnlocked: streakStarter,
          ),
          const SizedBox(width: 16),
          _buildBadge(
            icon: '👑',
            title: 'Streak Master',
            description: '7-day logging streak',
            isUnlocked: streakMaster,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String icon, required String title, required String description, required bool isUnlocked}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? AppColors.primary : Colors.transparent, width: 2),
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 40, color: isUnlocked ? Colors.black : Colors.grey.withOpacity(0.5))),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked ? AppColors.textDark : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? AppColors.textLight : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    final avatars = ['🥑', '🌱', '🍎', '🥦', '🥕', '🍓', '🥝', '🍑', '🐶', '🐱', '🐼', '🦊', '🐻', '🐰', '🐯', '🦁'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose your avatar', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = avatars[index];
                    return GestureDetector(
                      onTap: () {
                        Provider.of<AppState>(context, listen: false).updateAvatar(avatar);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: Center(
                          child: Text(avatar, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
