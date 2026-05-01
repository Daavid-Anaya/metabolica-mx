import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../domain/gamification_data.dart';
import 'gamification_controller.dart';
import '../../auth/presentation/profile_action_button.dart';

class GamificationView extends ConsumerWidget {
  const GamificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retos & Gamificación'),
        actions: const [
          ProfileActionButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildXpBanner(state),
            const SizedBox(height: 24),
            _buildSectionTitle('RETOS SEMANALES'),
            const SizedBox(height: 12),
            ...weeklyChallenges.map((c) => _buildChallengeCard(c, state, ref)),
            const SizedBox(height: 24),
            _buildSectionTitle('INSIGNIAS'),
            const SizedBox(height: 12),
            _buildBadgesGrid(state),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildXpBanner(GamificationState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF0EA5E9)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mi Progreso', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Sube de nivel cumpliendo retos', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${state.xp}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const Text('XP TOTAL', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip('${state.completedChallenges.values.where((v) => v).length}/${weeklyChallenges.length}', 'Retos', '🎯'),
              _buildStatChip('${state.unlockedBadges.values.where((v) => v).length}/${gamificationBadges.length}', 'Insignias', '🎖️'),
              _buildStatChip('${state.microcursosCompletados}', 'Cursos', '🎓'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, GamificationState state, WidgetRef ref) {
    final isCompleted = state.completedChallenges[challenge.id] ?? false;
    final progress = state.challengeProgress[challenge.id] ?? [];
    final completedSteps = progress.where((v) => v).length;
    final pct = progress.isNotEmpty ? completedSteps / progress.length : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCompleted ? AppColors.low.withValues(alpha: 0.5) : AppColors.border, width: isCompleted ? 2 : 1),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: challenge.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(challenge.emoji, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(challenge.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(
          isCompleted ? '✅ Completado' : '$completedSteps/${challenge.meta} ${challenge.unit}',
          style: TextStyle(fontSize: 11, color: isCompleted ? AppColors.low : AppColors.muted, fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('+${challenge.xp} XP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCompleted ? AppColors.low : challenge.color)),
            Icon(isCompleted ? Icons.check_circle : Icons.keyboard_arrow_down, color: isCompleted ? AppColors.low : AppColors.muted, size: 18),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.description, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 16),
                const Text('PASOS DEL RETO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                const SizedBox(height: 8),
                ...challenge.steps.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final step = entry.value;
                  final isDone = progress[idx];

                  return GestureDetector(
                    onTap: () => ref.read(gamificationProvider.notifier).toggleStep(challenge.id, idx),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.low.withValues(alpha: 0.05) : AppColors.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDone ? AppColors.low.withValues(alpha: 0.3) : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDone ? AppColors.low : AppColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: isDone 
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : Text('${idx + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(step, style: TextStyle(fontSize: 12, color: isDone ? AppColors.muted : AppColors.text, decoration: isDone ? TextDecoration.lineThrough : null)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? AppColors.low : challenge.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(GamificationState state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: gamificationBadges.length,
      itemBuilder: (context, index) {
        final badge = gamificationBadges[index];
        final isUnlocked = state.unlockedBadges[badge.id] ?? false;

        return GestureDetector(
          onTap: () => _showBadgeDetail(context, badge, isUnlocked),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked ? badge.color.withValues(alpha: 0.1) : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isUnlocked
                      ? badge.color.withValues(alpha: 0.4)
                      : AppColors.border,
                  width: isUnlocked ? 2 : 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.2,
                  child: Text(badge.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppColors.text : AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  isUnlocked ? '✓ Ganada' : '🔒',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppColors.low : AppColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetail(BuildContext context, Badge badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: badge.color.withValues(alpha: 0.2), width: 2),
                ),
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.3,
                  child: Text(badge.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.low.withValues(alpha: 0.1) : AppColors.border,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isUnlocked ? 'DESBLOQUEADA' : 'BLOQUEADA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? AppColors.low : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.text),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CONDICIÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1.1)),
                    const SizedBox(height: 4),
                    Text(_getConditionText(badge), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getConditionText(Badge badge) {
    switch (badge.conditionType) {
      case 'reto':
        return 'Completa el reto: "${weeklyChallenges.firstWhere((c) => c.id == badge.conditionKey).title}"';
      case 'bool':
        return 'Realiza y guarda un cálculo en la Calculadora IARRI';
      case 'gte':
        return 'Completa ${badge.conditionValue} microcursos educativos';
      default:
        return 'Condición especial';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
        letterSpacing: 1.1,
      ),
    );
  }
}
