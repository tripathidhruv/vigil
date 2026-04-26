import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { idle, loading, success, error }

enum UserRole { manager, staff }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userEmail;
  final String? userName;
  final UserRole role;
  final bool isLoggedIn;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.userEmail,
    this.userName,
    this.role = UserRole.manager,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userEmail,
    String? userName,
    UserRole? role,
    bool? isLoggedIn,
  }) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        userEmail: userEmail ?? this.userEmail,
        userName: userName ?? this.userName,
        role: role ?? this.role,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 1200));
    final isManager = !email.toLowerCase().contains('staff');
    state = state.copyWith(
      status: AuthStatus.success,
      userEmail: email,
      userName: isManager ? 'James Harrington' : 'Sarah Chen',
      role: isManager ? UserRole.manager : UserRole.staff,
      isLoggedIn: true,
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(
      status: AuthStatus.success,
      userEmail: email,
      userName: name.isEmpty ? 'New User' : name,
      role: UserRole.manager,
      isLoggedIn: true,
    );
  }

  void signOut() {
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
