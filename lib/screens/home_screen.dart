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
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late WaterService _waterService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double waterIntake = 0.0;
  double dailyGoal = 2.5;
  List<Map<String, dynamic>> waterIntakeHistory = [];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _waterService = _getIt.get<WaterService>();

    _loadWaterIntake();
    _loadWaterIntakeHistory();
    _loadDailyGoal();
  }

  Future<void> _loadWaterIntake() async {
    try {
      final userId = _authService.getUserId();
      final storedWaterIntake = await _waterService.getWaterIntake(userId);
      setState(() {
        waterIntake = storedWaterIntake;
      });
    } catch (e) {
      print("Error loading water intake: $e");
    }
  }

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
        waterIntakeHistory = historyList;
      });
    } catch (e) {
      print("Error loading water intake history: $e");
    }
  }

 void _addWater(double amount) {
  setState(() {
    waterIntake += amount;
    if (waterIntake >= dailyGoal) {
      waterIntake = dailyGoal;
      _showGoalReachedDialog(); // Show goal reached popup
    }
    waterIntakeHistory.add({
      'amount': amount,
      'time': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
    });
  });

  try {
    final userId = _authService.getUserId();
    _waterService.updateWaterIntake(userId, waterIntake);
  } catch (e) {
    print("Error updating water intake: $e");
  }

  try {
    final userId = _authService.getUserId();
    _firestore.collection('waterIntakeHistory').doc(userId).collection('intakes').add({
      'amount': amount,
      'timestamp': DateTime.now(),
    });
  } catch (e) {
    print("Error updating water intake history: $e");
  }
}
void _showGoalReachedDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Goal Reached!"),
        content: Text("Congratulations! You've reached your daily water intake goal 🎉"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

  Future<void> _loadDailyGoal() async {
    try {
      final userId = _authService.getUserId();
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?['dailyGoal'] != null) {
        setState(() {
          dailyGoal = doc.data()?['dailyGoal'];
        });
      }
    } catch (e) {
      print("Error loading daily goal: $e");
    }
  }

  Future<void> _updateDailyGoal(double newGoal) async {
    try {
      final userId = _authService.getUserId();
      await _firestore.collection('users').doc(userId).set({
        'dailyGoal': newGoal,
      }, SetOptions(merge: true));
      setState(() {
        dailyGoal = newGoal;
      });
    } catch (e) {
      print("Error updating daily goal: $e");
    }
  }

  void _resetWaterIntake() {
    setState(() {
      waterIntake = 0.0;
      waterIntakeHistory.clear();
    });

    try {
      final userId = _authService.getUserId();
      _waterService.updateWaterIntake(userId, waterIntake);
    } catch (e) {
      print("Error resetting water intake: $e");
    }
  }

  void _showGoalDialog() {
    TextEditingController goalController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Daily Goal"),
          content: SingleChildScrollView(
            child: TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Enter new goal in liters"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                double? newGoal = double.tryParse(goalController.text);
                if (newGoal != null && newGoal > 0) {
                  _updateDailyGoal(newGoal);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydration Tracker"),
        actions: [
  Row(
    children: [
      Text("Logout", style: TextStyle(color: Colors.red, fontSize: 16)),
      IconButton(
        onPressed: () async {
          bool result = await _authService.logout();
          if (result) {
            _navigationService.pushReplacementNamed("/login");
          }
        },
        color: Colors.red,
        icon: const Icon(Icons.logout),
      ),
    ],
  ),
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
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton(
      onPressed: _showGoalDialog,
      child: Text("Set Daily Goal"),
    ),
    ElevatedButton(
      onPressed: _resetWaterIntake,
      child: Text("Reset Water Intake"),
    ),
  ],
),
const SizedBox(height: 20),

            Expanded(
  child: ListView.builder(
    itemCount: waterIntakeHistory.length,
    itemBuilder: (context, index) {
      final entry = waterIntakeHistory[index];
      return ListTile(
        title: Text("${entry['amount']}L taken"),
        subtitle: Text("Date: ${entry['time']}"),
      );
    },
  ))
          ],
        ),
      ),
    );
  }
}
