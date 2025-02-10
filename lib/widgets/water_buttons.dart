import 'package:flutter/material.dart';

class WaterButtons extends StatelessWidget {
  final Function(double) onWaterAdd;

  const WaterButtons({Key? key, required this.onWaterAdd}) : super(key: key);

  Widget _waterButton(double amount, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.blueAccent,
          shadowColor: Colors.blueGrey,
          elevation: 5,
        ),
        onPressed: () => onWaterAdd(amount),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_drink, color: Colors.white, size: 30),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _waterButton(0.25, "250ml"),
        _waterButton(0.5, "500ml"),
        _waterButton(1.0, "1L"),
      ],
    );
  }
}
