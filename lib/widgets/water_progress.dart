import 'package:flutter/material.dart';

class WaterProgress extends StatelessWidget {
  final double waterIntake;
  final double dailyGoal;

  const WaterProgress({required this.waterIntake, required this.dailyGoal});

  @override
  Widget build(BuildContext context) {
    double progress = waterIntake / dailyGoal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Water Intake: ${waterIntake.toStringAsFixed(2)}L',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          'Daily Goal: ${dailyGoal.toStringAsFixed(2)}L',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 10),
        CircularProgressIndicator(
          value: progress,
          color: Colors.blueAccent,
          backgroundColor: Colors.blue.shade100,
          strokeWidth: 6,
        ),
        const SizedBox(height: 10),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
