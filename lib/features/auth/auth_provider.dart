import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';

enum UserRole { manager, staff, guest }
enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;
  final bool isLoggedIn;

  UserRole get role {
    if (user?.role == 'manager') return UserRole.manager;
    if (user?.role == 'guest') return UserRole.guest;
    return UserRole.staff;
  }
  
  String? get userName => user?.name;
  String? get userEmail => user?.email;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.user,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
    bool? isLoggedIn,
  }) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        user: user ?? this.user,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void signIn(String email, String password) {
    if (email == 'manager@vigil.com' && password == 'manager123') {
      state = state.copyWith(
        status: AuthStatus.success,
        isLoggedIn: true,
        user: const UserModel(
          uid: 'manager-uid',
          email: 'manager@vigil.com',
          name: 'Hotel Manager',
          role: 'manager',
          onDuty: true,
          department: 'Management',
        ),
      );
    } else if (email == 'staff@vigil.com' && password == 'staff123') {
      state = state.copyWith(
        status: AuthStatus.success,
        isLoggedIn: true,
        user: const UserModel(
          uid: 'staff_001',
          email: 'staff@vigil.com',
          name: 'James Harrington',
          role: 'staff',
          onDuty: true,
          department: 'Operations',
        ),
      );
    } else if (email == 'guest@vigil.com' && password == 'guest123') {
      state = state.copyWith(
        status: AuthStatus.success,
        isLoggedIn: true,
        user: const UserModel(
          uid: 'guest-uid',
          email: 'guest@vigil.com',
          name: 'Guest User',
          role: 'guest',
          onDuty: false,
          department: 'Guest',
        ),
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid credentials. Please check the hint.',
      );
    }
  }

  void register(String email, String password, String name) {
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Registration is disabled in local mode.',
    );
  }

  void signOut() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
