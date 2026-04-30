import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Pantalla: $title')),
    );
  }
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderScreen('Inicio'),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PlaceholderScreen('Login'),
    ),
  ],
);
