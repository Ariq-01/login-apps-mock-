import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_page.dart';
import 'features/login/login.dart';
import 'provider/auth_firebase.dart';

void main() {
  runApp(
    // ProviderScope untuk handling auth token & prevent multiple login
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen auth state untuk auto-login handling
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Routes untuk navigation
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
      },
      // Routing berdasarkan auth state
      home: authState.when(
        data: (user) {
          // Jika user sudah login, langsung ke Home
          if (user != null) {
            return const HomePage();
          }
          // Jika belum login, ke Login Page
          return const LoginPage();
        },
        loading: () => const SplashScreen(),
        error: (error, stackTrace) => const LoginPage(),
      ),
    );
  }
}

// Simple splash screen while checking auth state
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
