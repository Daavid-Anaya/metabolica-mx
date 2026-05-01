import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/main_shell.dart';
import '../features/calculator/presentation/test_view.dart';
import '../features/auth/presentation/login_view.dart';
import '../features/auth/presentation/register_view.dart';
import '../features/auth/presentation/profile_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/test',
      builder: (context, state) => const TestView(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileView(),
    ),
  ],
);
