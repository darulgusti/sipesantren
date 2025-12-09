import 'package:cloud_firestore/cloud_firestore.dart';

class WeightConfigModel {
  static const String collectionName = 'settings'; // Or 'config', to store global settings
  final String id; // Document ID, might be a fixed 'grading_weights'
  final double tahfidz;
  final double fiqh;
  final double bahasaArab;
  final double akhlak;
  final double kehadiran;
  final int maxSantriPerRoom; // New field

  WeightConfigModel({
    required this.id,
    required this.tahfidz,
    required this.fiqh,
    required this.bahasaArab,
    required this.akhlak,
    required this.kehadiran,
    this.maxSantriPerRoom = 6, // Default
  });

  factory WeightConfigModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WeightConfigModel(
      id: doc.id,
      tahfidz: (data['tahfidz'] as num?)?.toDouble() ?? 0.30,
      fiqh: (data['fiqh'] as num?)?.toDouble() ?? 0.20,
      bahasaArab: (data['bahasaArab'] as num?)?.toDouble() ?? 0.20,
      akhlak: (data['akhlak'] as num?)?.toDouble() ?? 0.20,
      kehadiran: (data['kehadiran'] as num?)?.toDouble() ?? 0.10,
      maxSantriPerRoom: (data['maxSantriPerRoom'] as int?) ?? 6,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tahfidz': tahfidz,
      'fiqh': fiqh,
      'bahasaArab': bahasaArab,
      'akhlak': akhlak,
      'kehadiran': kehadiran,
      'maxSantriPerRoom': maxSantriPerRoom,
    };
  }
}
