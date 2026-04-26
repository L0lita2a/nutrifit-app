import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final String category;

  FoodItem({required this.id, required this.name, required this.calories, required this.category});
}

class WorkoutItem {
  final String id;
  final String name;
  final int minutes;
  final String category;

  WorkoutItem({required this.id, required this.name, required this.minutes, required this.category});
}

class AppState extends ChangeNotifier {
  // Goals
  int dailyCalorieGoal = 2000;
  int dailyWaterGoal = 2500;

  // State
  List<FoodItem> foodLogs = [];
  int waterConsumed = 0;
  List<WorkoutItem> workoutLogs = [];
  List<double> weightLogs = []; 
  
  // Profile
  String avatar = '🥑';
  double height = 170.0;
  double weight = 68.5;
  int age = 28;
  int currentStreak = 0;
  DateTime? lastLoggedDate;

  // Loading state
  bool isLoading = true;
  bool isProfileSetup = true;

  StreamSubscription? _profileSub;
  StreamSubscription? _foodSub;
  StreamSubscription? _waterSub;
  StreamSubscription? _workoutSub;
  StreamSubscription? _weightSub;

  AppState() {
    _initStreams();
  }

  void _initStreams() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToData(user.uid);
      } else {
        _unsubscribeAll();
        // Reset state
        foodLogs.clear();
        waterConsumed = 0;
        workoutLogs.clear();
        weightLogs.clear();
        isLoading = false;
        notifyListeners();
      }
    });
  }

  void _subscribeToData(String uid) {
    isLoading = true;
    _streamsLoaded = 0;
    notifyListeners();

    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(uid);

    // Profile listener
    _profileSub = userRef.snapshots().listen((doc) {
      if (doc.exists) {
        isProfileSetup = true;
        final data = doc.data()!;
        dailyCalorieGoal = data['dailyCalorieGoal'] ?? 2000;
        dailyWaterGoal = data['dailyWaterGoal'] ?? 2500;
        avatar = data['avatar'] ?? '🥑';
        height = (data['height'] ?? 170.0).toDouble();
        weight = (data['weight'] ?? 68.5).toDouble();
        age = data['age'] ?? 28;
        currentStreak = data['currentStreak'] ?? 0;
        lastLoggedDate = data['lastLoggedDate']?.toDate();
      } else {
        isProfileSetup = false;
      }
      _checkLoadingDone();
    });

    // Get today's bounds
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Food logs listener (only today)
    _foodSub = userRef.collection('foodLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots().listen((snapshot) {
      foodLogs = snapshot.docs.map((doc) => FoodItem(
        id: doc.id,
        name: doc['name'],
        calories: doc['calories'],
        category: doc['category'],
      )).toList();
      _checkLoadingDone();
    });

    // Water logs listener (only today)
    _waterSub = userRef.collection('waterLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots().listen((snapshot) {
      waterConsumed = snapshot.docs.fold(0, (sum, doc) => sum + (doc['amount'] as int));
      _checkLoadingDone();
    });

    // Workout logs listener (only today)
    _workoutSub = userRef.collection('workoutLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots().listen((snapshot) {
      workoutLogs = snapshot.docs.map((doc) => WorkoutItem(
        id: doc.id,
        name: doc['name'],
        minutes: doc['minutes'],
        category: doc['category'],
      )).toList();
      _checkLoadingDone();
    });

    // Weight logs listener (All time for chart)
    _weightSub = userRef.collection('weightLogs')
        .orderBy('timestamp')
        .snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        weightLogs = snapshot.docs.map((doc) => (doc['weight'] as num).toDouble()).toList();
        weight = weightLogs.last; // Update current weight
      } else {
        weightLogs = [70.5, 70.2, 69.8, 69.5, 69.0, 68.8, 68.5]; // Default fake data for demo if empty
      }
      _checkLoadingDone();
    });
  }

  int _streamsLoaded = 0;
  void _checkLoadingDone() {
    _streamsLoaded++;
    if (_streamsLoaded >= 5 && isLoading) {
      isLoading = false;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void _unsubscribeAll() {
    _profileSub?.cancel();
    _foodSub?.cancel();
    _waterSub?.cancel();
    _workoutSub?.cancel();
    _weightSub?.cancel();
  }

  @override
  void dispose() {
    _unsubscribeAll();
    super.dispose();
  }

  // Getters
  int get caloriesConsumed => foodLogs.fold(0, (sum, item) => sum + item.calories);
  int get caloriesRemaining => dailyCalorieGoal - caloriesConsumed;
  double get waterProgress => (waterConsumed / dailyWaterGoal).clamp(0.0, 1.0);
  int get workoutMinutes => workoutLogs.fold(0, (sum, item) => sum + item.minutes);

  Future<void> _updateStreak() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreak = currentStreak;
    DateTime? newLastLoggedDate = lastLoggedDate;

    if (lastLoggedDate == null) {
      newStreak = 1;
      newLastLoggedDate = now;
    } else {
      final lastLogDay = DateTime(lastLoggedDate!.year, lastLoggedDate!.month, lastLoggedDate!.day);
      final diff = today.difference(lastLogDay).inDays;
      
      if (diff == 1) {
        newStreak += 1;
        newLastLoggedDate = now;
      } else if (diff > 1) {
        newStreak = 1;
        newLastLoggedDate = now;
      } else if (diff == 0) {
        newLastLoggedDate = now;
      }
    }

    if (newStreak != currentStreak || newLastLoggedDate != lastLoggedDate) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'currentStreak': newStreak,
        'lastLoggedDate': newLastLoggedDate,
      });
    }
  }

  // Actions
  Future<void> addFood(String name, int calories, String category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('foodLogs').add({
      'name': name,
      'calories': calories,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _updateStreak();
  }

  Future<void> addWater(int amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('waterLogs').add({
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _updateStreak();
  }

  Future<void> addWorkout(String name, int minutes, String category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('workoutLogs').add({
      'name': name,
      'minutes': minutes,
      'category': category,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _updateStreak();
  }

  Future<void> updateAvatar(String newAvatar) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'avatar': newAvatar,
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
