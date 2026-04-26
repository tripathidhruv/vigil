import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseProvider = Provider<FirebaseService>((ref) => FirebaseService());

class FirebaseService {
  // Mock Firebase service for initial build
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always succeed in mock
  }
}
