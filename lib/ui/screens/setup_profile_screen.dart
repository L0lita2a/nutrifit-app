import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class SetupProfileScreen extends StatefulWidget {
  final String uid;
  final String name;

  const SetupProfileScreen({Key? key, required this.uid, required this.name}) : super(key: key);

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  String _selectedGender = 'Female';
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';
  String _selectedGoal = 'Maintain Weight';
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active'
  ];

  Future<void> _finishSetup() async {
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0;

    if (age <= 0 || weight <= 0 || height <= 0) {
      setState(() {
        _errorMessage = 'Please enter valid numbers for age, weight, and height.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Calculate BMR using Mifflin-St Jeor
      double bmr;
      if (_selectedGender == 'Male') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      }

      // Calculate daily caloric needs
      double activityFactor = 1.2;
      switch (_selectedActivityLevel) {
        case 'Sedentary':
          activityFactor = 1.2;
          break;
        case 'Lightly Active':
          activityFactor = 1.375;
          break;
        case 'Moderately Active':
          activityFactor = 1.55;
          break;
        case 'Very Active':
          activityFactor = 1.725;
          break;
      }

      int dailyCaloricNeeds = (bmr * activityFactor).round();
      if (_selectedGoal == 'Lose Weight') {
        dailyCaloricNeeds -= 500;
      } else if (_selectedGoal == 'Gain Weight') {
        dailyCaloricNeeds += 500;
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'name': widget.name,
        'dailyCalorieGoal': dailyCaloricNeeds,
        'dailyWaterGoal': 2500, // default
        'avatar': '🥑', // default
        'height': height,
        'weight': weight,
        'age': age,
        'gender': _selectedGender,
        'activityLevel': _selectedActivityLevel,
        'goal': _selectedGoal,
      });

      if (mounted) {
        Navigator.pop(context); // Pops SetupProfileScreen, revealing MainLayout
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Setup Profile',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Let\'s get to know you!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us calculate your daily caloric needs accurately.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: AppColors.textLight,
                    ),
              ),
              const SizedBox(height: 32),

              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Gender Toggle
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = 'Male'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Male' ? AppColors.primaryLight : Colors.white,
                          border: Border.all(
                            color: _selectedGender == 'Male' ? AppColors.primary : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Male',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedGender == 'Male' ? AppColors.primary : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = 'Female'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Female' ? AppColors.primaryLight : Colors.white,
                          border: Border.all(
                            color: _selectedGender == 'Female' ? AppColors.primary : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Female',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedGender == 'Female' ? AppColors.primary : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Age
              _buildInputField('Age (years)', 'e.g. 25', _ageController, TextInputType.number),
              const SizedBox(height: 24),

              // Weight
              _buildInputField('Weight (kg)', 'e.g. 70', _weightController, TextInputType.number),
              const SizedBox(height: 24),

              // Height
              _buildInputField('Height (cm)', 'e.g. 175', _heightController, TextInputType.number),
              const SizedBox(height: 24),

              // Activity Level Dropdown
              const Text('Activity Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedActivityLevel,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                    items: _activityLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedActivityLevel = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Goal Selection
              const Text('Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildGoalSelection(),
              const SizedBox(height: 48),

              // Finish Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Finish Set Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelection() {
    return Column(
      children: [
        _buildGoalOption('Lose Weight', Icons.trending_down),
        const SizedBox(height: 12),
        _buildGoalOption('Maintain Weight', Icons.remove),
        const SizedBox(height: 12),
        _buildGoalOption('Gain Weight', Icons.trending_up),
      ],
    );
  }

  Widget _buildGoalOption(String title, IconData icon) {
    final isSelected = _selectedGoal == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade600),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
