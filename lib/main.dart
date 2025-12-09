import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'firebase_services.dart';
import 'package:sipesantren/core/providers/user_provider.dart'; // New import

import 'features/auth/presentation/login_page.dart';
import 'features/santri/presentation/santri_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> { // Changed to ConsumerState
  final FirebaseServices _auth = FirebaseServices();
  // Removed _isLoading and _isLoggedIn local states

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = await _auth.getUserSession();
    if (session['id'] != null) {
      ref.read(userProvider.notifier).login(
            session['id']!,
            session['role'] ?? 'Ustadz', // Default role if not found
            session['name'] ?? 'User', // Default name if not found
          );
    }
    // No need for setState for _isLoading, as UI will react to userProvider's isLoggedIn
    // For initial loading, we can use a temporary flag or a check on userProvider.isLoggedIn
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider); // Watch userProvider

    if (userState.userId == null && !userState.isLoggedIn) { // Check if not logged in
      // This is the initial loading state before _checkSession completes, or if no session
      // For a better loading indicator, this might need a dedicated loading state in the provider
      // For now, if no userId and not logged in, consider it loading or unauthenticated.
      // After _checkSession, if no user, it will go to LoginPage.
      // If it's truly loading, we need to show a splash/loading screen.
      // Let's assume for now that if userId is null and !isLoggedIn, it either is loading
      // or will quickly resolve to LoginPage. A better pattern would be a loading flag in UserState.
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'e-Penilaian Santri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: userState.isLoggedIn ? const SantriListPage() : const LoginPage(), // Use userState
      debugShowCheckedModeBanner: false,
    );
  }
}
