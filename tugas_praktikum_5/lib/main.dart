import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import 'add_transaction_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AuthService.instance.restoreSession();
  } catch (e) {
    debugPrint('Gagal memulihkan sesi: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      // MENGGUNAKAN NAMED ROUTES
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/add': (context) => const AddTransactionScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.instance.isLoggedIn
        ? const MainScreen()
        : const LoginScreen();
  }
}
