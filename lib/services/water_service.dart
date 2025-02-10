import 'package:cloud_firestore/cloud_firestore.dart';

class WaterService {
  final FirebaseFirestore firestore;

  WaterService({required this.firestore});

  Future<void> updateWaterIntake(String userId, double waterIntake) async {
    await firestore.collection('user_water_intakes').doc(userId).set({
      'waterIntake': waterIntake,
      'date': FieldValue.serverTimestamp(), // To track the time of the update
    }, SetOptions(merge: true));
  }

  Future<double> getWaterIntake(String userId) async {
    final docSnapshot = await firestore.collection('user_water_intakes').doc(userId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data()!['waterIntake'] ?? 0.0;
    }
    return 0.0; // Default if no data exists
  }
}
