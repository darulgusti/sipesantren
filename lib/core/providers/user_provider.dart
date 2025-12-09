import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserState {
  final String? userId;
  final String? userRole;
  final String? userName;
  final bool isLoggedIn;

  UserState({
    this.userId,
    this.userRole,
    this.userName,
    this.isLoggedIn = false,
  });

  UserState copyWith({
    String? userId,
    String? userRole,
    String? userName,
    bool? isLoggedIn,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  void login(String id, String role, String name) {
    state = state.copyWith(
      userId: id,
      userRole: role,
      userName: name,
      isLoggedIn: true,
    );
  }

  void logout() {
    state = UserState(); // Reset to default state
  }
}
