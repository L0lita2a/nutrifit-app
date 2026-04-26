import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: AppColors.background, // Pastel background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 48),
              _buildCaloriesRing(context, state),
              const SizedBox(height: 48),
              _buildNutritionSummary(context, state),
              const SizedBox(height: 56),
              _buildProgressSection(context, state),
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
              'Hello, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Ready to hit your goals today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (state.currentStreak > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${state.currentStreak} Day Streak!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLight,
          child: Text(state.avatar, style: const TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _buildCaloriesRing(BuildContext context, AppState state) {
    double percent = (state.caloriesConsumed / state.dailyCalorieGoal).clamp(0.0, 1.0);
    return Center(
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 12.0,
            animation: true,
            animateFromLastPercent: true,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppColors.primary,
            backgroundColor: AppColors.primaryLight.withOpacity(0.3),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${state.caloriesConsumed}',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w200,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Eaten',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Goal: ${state.dailyCalorieGoal} kcal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryItem(Icons.restaurant, 'Protein', '40/80 g', AppColors.primary),
        _buildSummaryItem(Icons.fitness_center, 'Workouts', '${state.workoutLogs.length}/5 times', Colors.purpleAccent),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String title, String value, Color accentColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keep up the great work!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 32),
        _buildFloatingProgressBar(
          title: 'Hydration',
          progress: state.waterProgress,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 28),
        _buildFloatingProgressBar(
          title: 'Weight',
          progress: 0.6, // Example static progress
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildFloatingProgressBar({required String title, required double progress, required Color color}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ],
    );
  }
}
