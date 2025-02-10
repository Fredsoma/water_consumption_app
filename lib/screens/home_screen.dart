import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:water_consumption_app/services/auth_service.dart';
import 'package:water_consumption_app/services/navigation_service.dart';
import 'package:water_consumption_app/services/water_service.dart';
import 'package:water_consumption_app/widgets/water_progress.dart';
import 'package:water_consumption_app/widgets/water_history.dart';
import 'package:water_consumption_app/widgets/water_buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for date formatting

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late WaterService _waterService;  // WaterService instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double waterIntake = 0.0;
  double dailyGoal = 2.5; // in liters
  List<Map<String, dynamic>> waterIntakeHistory = []; // Store water intake entries

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _waterService = _getIt.get<WaterService>(); // Initialize WaterService

    _loadWaterIntake();  // Fetch the water intake when the user logs in
    _loadWaterIntakeHistory();  // Fetch water intake history on load
  }

  // Fetch the water intake for the user
  Future<void> _loadWaterIntake() async {
    try {
      final userId = _authService.getUserId(); // Get the logged-in user's ID
      final storedWaterIntake = await _waterService.getWaterIntake(userId);
      setState(() {
        waterIntake = storedWaterIntake;
      });
    } catch (e) {
      print("Error loading water intake: $e");
    }
  }

  // Fetch water intake history for the user from Firestore
  Future<void> _loadWaterIntakeHistory() async {
    try {
      final userId = _authService.getUserId();
      final historySnapshot = await _firestore
          .collection('waterIntakeHistory')
          .doc(userId)
          .collection('intakes')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> historyList = [];
      for (var doc in historySnapshot.docs) {
        historyList.add({
          'amount': doc['amount'],
          'time': DateFormat('yyyy-MM-dd hh:mm a').format(doc['timestamp'].toDate()),
        });
      }

      setState(() {
        waterIntakeHistory = historyList;  // Update water intake history
      });
    } catch (e) {
      print("Error loading water intake history: $e");
    }
  }

  void _addWater(double amount) {
    setState(() {
      waterIntake += amount;
      if (waterIntake >= dailyGoal) {
        waterIntake = dailyGoal; // Max water intake to the daily goal
      }
      // Track the water intake with the timestamp
      waterIntakeHistory.add({
        'amount': amount,
        'time': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()), // Format the time with date
      });
    });

    // Update water intake in Firestore
    try {
      final userId = _authService.getUserId(); // Get the logged-in user's ID
      _waterService.updateWaterIntake(userId, waterIntake); // Update the intake in Firestore
    } catch (e) {
      print("Error updating water intake: $e");
    }

    // Update the intake history in Firestore
    try {
      final userId = _authService.getUserId();
      _firestore
          .collection('waterIntakeHistory')
          .doc(userId)
          .collection('intakes')
          .add({
            'amount': amount,
            'timestamp': DateTime.now(),  // Store the current timestamp
          });
    } catch (e) {
      print("Error updating water intake history: $e");
    }
  }

  // Method to reset water intake to 0 manually
  void _resetWaterIntake() {
    setState(() {
      waterIntake = 0.0; // Reset water intake to 0
      waterIntakeHistory.clear(); // Clear the intake history
    });

    // Optionally update Firestore to reflect the reset
    try {
      final userId = _authService.getUserId(); // Get the logged-in user's ID
      _waterService.updateWaterIntake(userId, waterIntake); // Update the intake in Firestore
    } catch (e) {
      print("Error resetting water intake: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydration Tracker"),
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _navigationService.pushReplacementNamed("/login");
              }
            },
            color: Colors.red,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            WaterProgress(waterIntake: waterIntake, dailyGoal: dailyGoal),
            const SizedBox(height: 20),
            WaterButtons(onWaterAdd: _addWater),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetWaterIntake, // Reset button click handler
              child: const Text("Reset Water Intake"),
            ),
            const SizedBox(height: 20),
            // Display water intake history
            Expanded(
              child: ListView.builder(
                itemCount: waterIntakeHistory.length,
                itemBuilder: (context, index) {
                  final entry = waterIntakeHistory[index];
                  return ListTile(
                    title: Text("${entry['amount']}L taken"),
                    subtitle: Text("Date: ${entry['time']}"), // Show both date and time
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
