import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/firebase_services.dart'; // New import

class UserState {
  final String? userId;
  final String? userRole;
  final String? userName;
  final String? requestedRole;
  final String? requestStatus;
  final bool isLoggedIn;
  final bool isLoadingSession; // New field

  UserState({
    this.userId,
    this.userRole,
    this.userName,
    this.requestedRole,
    this.requestStatus,
    this.isLoggedIn = false,
    this.isLoadingSession = true, // Default to true
  });

  UserState copyWith({
    String? userId,
    String? userRole,
    String? userName,
    String? requestedRole,
    String? requestStatus,
    bool? isLoggedIn,
    bool? isLoadingSession, // New field
  }) {
    return UserState(
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
      requestedRole: requestedRole ?? this.requestedRole,
      requestStatus: requestStatus ?? this.requestStatus,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoadingSession: isLoadingSession ?? this.isLoadingSession, // New field
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref); // Pass ref to UserNotifier
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref; // Store ref

  UserNotifier(this._ref) : super(UserState()); // Accept ref in constructor

  void login(String id, String role, String name, {String? requestedRole, String? requestStatus}) {
    // We recreate UserState to ensure we can set fields to null if needed, 
    // or we'd need a more complex copyWith.
    // However, to fix the specific issue of clearing status, we add clearRequestStatus.
    // But login() acts as a "set state" here. 
    // Let's rely on clearRequestStatus for the specific action.
    state = state.copyWith(
      userId: id,
      userRole: role,
      userName: name,
      requestedRole: requestedRole,
      requestStatus: requestStatus,
      isLoggedIn: true,
      isLoadingSession: false,
    );
  }

  void clearRequestStatus() {
    state = UserState(
      userId: state.userId,
      userRole: state.userRole,
      userName: state.userName,
      isLoggedIn: state.isLoggedIn,
      isLoadingSession: state.isLoadingSession,
      requestedRole: null,
      requestStatus: null,
    );
  }

  Future<void> logout() async { // Make it async
    await _ref.read(firebaseServicesProvider).logout(); // Call FirebaseServices logout
    state = UserState(isLoadingSession: false); // Reset to default state, session check completed
  }

  void sessionCheckCompleted() {
    state = state.copyWith(isLoadingSession: false);
  }
}
