import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? requestedRole;
  final String? requestStatus; // 'pending', 'rejected', etc.
  final String hashedPassword; // This will store salt:::hash
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.requestedRole,
    this.requestStatus,
    required this.hashedPassword,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Ustadz', // Default role if not specified
      requestedRole: data['requested_role'],
      requestStatus: data['request_status'],
      hashedPassword: data['hashed_password'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'requested_role': requestedRole,
      'request_status': requestStatus,
      'hashed_password': hashedPassword,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? requestedRole,
    String? requestStatus,
    String? hashedPassword,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      requestedRole: requestedRole ?? this.requestedRole,
      requestStatus: requestStatus ?? this.requestStatus,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
