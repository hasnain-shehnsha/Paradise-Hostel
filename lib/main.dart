import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: HostelAdminApp()));
}

class HostelAdminApp extends StatelessWidget {
  const HostelAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (user) {
        return FutureBuilder(
          future: Future.delayed(const Duration(seconds: 2)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SplashScreen();
            }
            if (user == null) {
              return const LoginScreen();
            } else {
              return const HomePage();
            }
          },
        );
      },
      loading: () => const SplashScreen(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
