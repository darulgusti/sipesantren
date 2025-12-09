import 'package:cloud_firestore/cloud_firestore.dart';

class MapelModel {
  final String id;
  final String name;

  MapelModel({
    required this.id,
    required this.name,
  });

  factory MapelModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MapelModel(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
