import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metabolica_mx/features/home/presentation/home_view.dart';
import 'package:metabolica_mx/features/calculator/presentation/calculator_view.dart';
import 'package:metabolica_mx/features/recommendations/presentation/recommendations_view.dart';
import 'package:metabolica_mx/features/education/presentation/education_view.dart';
import '../../../config/app_colors.dart';

final navigationProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final screens = [
      const HomeView(),
      const _Placeholder('Mapa'),
      const CalculatorView(),
      const RecommendationsView(),
      const EducationView(),
      const _Placeholder('Retos'),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.07),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(navigationProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.muted,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Inicio'),
            BottomNavigationBarItem(icon: Text('🗺️', style: TextStyle(fontSize: 20)), label: 'Mapa'),
            BottomNavigationBarItem(icon: Text('🧮', style: TextStyle(fontSize: 20)), label: 'Calcular'),
            BottomNavigationBarItem(icon: Text('🛡️', style: TextStyle(fontSize: 20)), label: 'Intervención'),
            BottomNavigationBarItem(icon: Text('📚', style: TextStyle(fontSize: 20)), label: 'Aprender'),
            BottomNavigationBarItem(icon: Text('🏆', style: TextStyle(fontSize: 20)), label: 'Retos'),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Pantalla: $title')),
    );
  }
}
