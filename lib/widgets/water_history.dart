import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WaterHistory extends StatelessWidget {
  final FirebaseFirestore firestore;

  const WaterHistory({Key? key, required this.firestore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('water_intakes')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var amount = data[index]['amount'];
            var date = (data[index]['date'] as Timestamp).toDate();
            var formattedDate = DateFormat('yMMMd').format(date);

            return ListTile(
              title: Text('Amount: $amount L'),
              subtitle: Text('Date: $formattedDate'),
              trailing: const Icon(Icons.history, color: Colors.blueAccent),
            );
          },
        );
      },
    );
  }
}
