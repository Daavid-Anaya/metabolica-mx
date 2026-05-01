import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gamification/presentation/gamification_controller.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final gamificationState = ref.watch(gamificationProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(user),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildKpiCard('🎖️', '${gamificationState.unlockedBadges.length}', 'Insignias', AppColors.accent3),
                const SizedBox(width: 12),
                _buildKpiCard('⚡', '${gamificationState.xp}', 'XP Total', AppColors.accent),
              ],
            ),
            const SizedBox(height: 24),
            _buildLogoutCard(context, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    final name = user?.userMetadata?['display_name'] ?? 'Usuario';
    final email = user?.email ?? 'Sin correo';
    final muni = user?.userMetadata?['municipality'] ?? 'No especificado';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: const Text('👤', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(muni, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.high.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text('🚪', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cerrar Sesión', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Tu progreso se mantendrá guardado', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.high,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Salir de la cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
