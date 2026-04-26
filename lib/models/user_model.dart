import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { manager, departmentHead, staff }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;       // "manager" | "department_head" | "staff"
  final String department; // "Security", "Engineering", "Front Desk", etc.
  final bool onDuty;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.onDuty = false,
    this.fcmToken,
  });

  UserRole get userRole {
    switch (role) {
      case 'manager':
        return UserRole.manager;
      case 'department_head':
        return UserRole.departmentHead;
      default:
        return UserRole.staff;
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: d['name'] as String? ?? 'Unknown',
      email: d['email'] as String? ?? '',
      role: d['role'] as String? ?? 'staff',
      department: d['department'] as String? ?? '',
      onDuty: d['onDuty'] as bool? ?? false,
      fcmToken: d['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'department': department,
        'onDuty': onDuty,
        'fcmToken': fcmToken,
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? department,
    bool? onDuty,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      onDuty: onDuty ?? this.onDuty,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
