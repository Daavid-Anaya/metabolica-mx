import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../domain/education_data.dart';
import 'education_controller.dart';

// ─── ROUTER PRINCIPAL ─────────────────────────────────────────────────────────

class EducationView extends ConsumerWidget {
  const EducationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationProvider);

    return switch (state.view) {
      EducationViewState.home       => const _HomeView(),
      EducationViewState.microcourse => const _MicrocourseView(),
      EducationViewState.lesson     => const _LessonView(),
      EducationViewState.evaluation => const _EvaluationView(),
    };
  }
}

// ─── HOME VIEW ────────────────────────────────────────────────────────────────

class _HomeView extends ConsumerWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(educationProvider);
    final notifier = ref.read(educationProvider.notifier);
    final progress = state.progress;

    final xp      = totalXp(progress);
    final level   = currentLevel(xp);
    final next    = nextLevel(xp);
    final xpToNext = next != null ? next.xpMin - level.xpMin : 0;
    final xpInLevel = next != null ? xp - level.xpMin : xp - level.xpMin;
    final progressFraction = (next != null && xpToNext > 0)
        ? (xpInLevel / xpToNext).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          '📚 Educación Interactiva',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Banner XP ──────────────────────────────────────────────
          _XpBanner(
            level: level,
            xp: xp,
            next: next,
            progressFraction: progressFraction,
          ),
          const SizedBox(height: 20),

          // ── Microcursos ────────────────────────────────────────────
          const Text(
            '🎯 Microcursos',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...microcourses.map(
            (mc) => _MicrocourseCard(
              mc: mc,
              progress: progress,
              onTap: () => notifier.openMicrocourse(mc),
            ),
          ),
          const SizedBox(height: 20),

          // ── Lecciones individuales ─────────────────────────────────
          const Text(
            '📖 Lecciones individuales',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...lessons.map(
            (lesson) => _LessonListTile(
              lesson: lesson,
              progress: progress,
              onTap: () => notifier.openLesson(lesson, fromMicrocourse: false),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── XP Banner ─────────────────────────────────────────────────────────────────

class _XpBanner extends StatelessWidget {
  final XpLevel level;
  final int xp;
  final XpLevel? next;
  final double progressFraction;

  const _XpBanner({
    required this.level,
    required this.xp,
    required this.next,
    required this.progressFraction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(level.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$xp XP acumulados',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nivel ${level.level}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hacia: ${next!.title}',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${next!.xpMin - xp} XP restantes',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 8,
                backgroundColor: AppColors.white.withValues(alpha: 0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Microcourse Card ──────────────────────────────────────────────────────────

class _MicrocourseCard extends StatelessWidget {
  final Microcourse mc;
  final Map<String, dynamic> progress;
  final VoidCallback onTap;

  const _MicrocourseCard({
    required this.mc,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done      = isMicrocourseCompleted(mc.id, progress);
    final completed = microcourseProgress(mc, progress);
    final total     = mc.lessonIds.length;
    final fraction  = total > 0 ? completed / total : 0.0;
    final color     = Color(mc.colorValue);
    final xpEarned  = progress['mc_${mc.id}_xp'] as int? ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(mc.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mc.title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              mc.levelName,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (done)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.low.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '✅ Completado',
                                style: TextStyle(
                                  color: AppColors.low,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (xpEarned > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mid.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'En progreso',
                                style: TextStyle(
                                  color: AppColors.mid,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+${mc.totalXp} XP disponibles',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.muted, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              mc.description,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completed/$total lecciones',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12),
                ),
                Text(
                  done ? '${mc.badgeEmoji} ${mc.badgeName}' : '',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lesson List Tile ──────────────────────────────────────────────────────────

class _LessonListTile extends StatelessWidget {
  final Lesson lesson;
  final Map<String, dynamic> progress;
  final VoidCallback onTap;

  const _LessonListTile({
    required this.lesson,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done  = progress['leccion_${lesson.id}_completada'] == true;
    final score = progress['leccion_${lesson.id}_puntaje'] as int?;
    final color = Color(lesson.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child:
                    Text(lesson.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (done && score != null)
                    Text(
                      '✅ Completada · $score/${lesson.quiz.isNotEmpty ? lesson.quiz.length : "—"} correctas',
                      style: const TextStyle(
                          color: AppColors.low, fontSize: 11),
                    )
                  else if (done)
                    const Text(
                      '✅ Completada',
                      style: TextStyle(color: AppColors.low, fontSize: 11),
                    )
                  else
                    const Text(
                      'Sin completar',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── MICROCOURSE VIEW ─────────────────────────────────────────────────────────

class _MicrocourseView extends ConsumerWidget {
  const _MicrocourseView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(educationProvider);
    final notifier = ref.read(educationProvider.notifier);
    final mc       = state.activeMicrocourse;

    if (mc == null) {
      return const Scaffold(
        body: Center(child: Text('Sin microcurso seleccionado')),
      );
    }

    final progress  = state.progress;
    final color     = Color(mc.colorValue);
    final done      = isMicrocourseCompleted(mc.id, progress);
    final completed = microcourseProgress(mc, progress);
    final total     = mc.lessonIds.length;
    final allDone   = completed == total;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => notifier.goBack(),
        ),
        title: Text(
          mc.title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(mc.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mc.levelName,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            mc.description,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      label: '$completed/$total lecciones',
                      color: color,
                    ),
                    _Chip(
                      label: '+${mc.totalXp} XP',
                      color: AppColors.mid,
                    ),
                  ],
                ),
                if (done) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.low.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${mc.badgeEmoji} ${mc.badgeName} desbloqueado!',
                      style: const TextStyle(
                        color: AppColors.low,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Lista de lecciones ─────────────────────────────────────
          const Text(
            'Lecciones',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...mc.lessonIds.asMap().entries.map((entry) {
            final idx      = entry.key;
            final lessonId = entry.value;
            final lesson   = lessonById(lessonId);
            if (lesson == null) return const SizedBox.shrink();

            final lessonDone =
                progress['leccion_${lessonId}_completada'] == true;
            final prevDone = idx == 0
                ? true
                : progress[
                        'leccion_${mc.lessonIds[idx - 1]}_completada'] ==
                    true;
            final locked = !lessonDone && !prevDone;

            return GestureDetector(
              onTap: locked
                  ? null
                  : () => notifier.openLesson(lesson, fromMicrocourse: true),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.bg
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: locked
                        ? AppColors.border
                        : color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: locked
                            ? AppColors.border
                            : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: locked
                            ? const Icon(Icons.lock,
                                size: 16, color: AppColors.muted)
                            : Text(lesson.emoji,
                                style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: TextStyle(
                          color: locked ? AppColors.muted : AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (lessonDone)
                      const Icon(Icons.check_circle,
                          color: AppColors.low, size: 18)
                    else if (!locked)
                      Icon(Icons.play_circle_outline,
                          color: color, size: 18)
                    else
                      const Icon(Icons.lock_outline,
                          color: AppColors.muted, size: 16),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── Botón evaluación ───────────────────────────────────────
          if (done)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.low.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.low.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events,
                      color: AppColors.low, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${mc.badgeEmoji} ${mc.badgeName} — Completado',
                    style: const TextStyle(
                      color: AppColors.low,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: allDone
                  ? () => notifier.openEvaluation(mc)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: allDone ? color : AppColors.border,
                foregroundColor: allDone ? Colors.white : AppColors.muted,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                allDone
                    ? '🎓 Ir a la Evaluación Final'
                    : '🔒 Completa todas las lecciones primero',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── LESSON VIEW ──────────────────────────────────────────────────────────────

class _LessonView extends ConsumerStatefulWidget {
  const _LessonView();

  @override
  ConsumerState<_LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends ConsumerState<_LessonView> {
  int _sectionIndex = 0;
  bool _inQuiz      = false;
  bool _submitted   = false;

  // índice respuesta seleccionada por pregunta (null = sin responder)
  late List<int?> _answers;

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _resetState() {
    final lesson =
        ref.read(educationProvider).activeLesson;
    final count = lesson?.quiz.length ?? 0;
    _answers = List.filled(count, null);
    _sectionIndex = 0;
    _inQuiz = false;
    _submitted = false;
  }

  int get _correctCount {
    final lesson = ref.read(educationProvider).activeLesson;
    if (lesson == null) return 0;
    int count = 0;
    for (int i = 0; i < lesson.quiz.length; i++) {
      if (_answers[i] == lesson.quiz[i].correctIndex) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(educationProvider);
    final notifier = ref.read(educationProvider.notifier);
    final lesson   = state.activeLesson;

    if (lesson == null) {
      return const Scaffold(
        body: Center(child: Text('Sin lección seleccionada')),
      );
    }

    final color      = Color(lesson.colorValue);
    final sections   = lesson.sections;
    final hasQuiz    = lesson.quiz.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () {
            notifier.goBack();
          },
        ),
        title: Row(
          children: [
            Text(lesson.emoji,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lesson.title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _submitted
          ? _buildResults(lesson, notifier, color)
          : _inQuiz
              ? _buildQuiz(lesson, notifier, color)
              : _buildContent(sections, hasQuiz, color),
    );
  }

  // ── Contenido ───────────────────────────────────────────────────────────────

  Widget _buildContent(
      List<LessonSection> sections, bool hasQuiz, Color color) {
    final section = sections[_sectionIndex];
    final isLast  = _sectionIndex == sections.length - 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicador de progreso (puntos)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sections.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _sectionIndex ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _sectionIndex
                      ? color
                      : color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Tarjeta de contenido
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        section.content,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón siguiente / quiz
          ElevatedButton(
            onPressed: () {
              if (isLast) {
                if (hasQuiz) {
                  setState(() => _inQuiz = true);
                } else {
                  // Sin quiz — marcar como completada directamente
                  final notifier = ref.read(educationProvider.notifier);
                  final lesson   = ref.read(educationProvider).activeLesson;
                  if (lesson != null) {
                    notifier.completeLesson(lesson.id, 0);
                  }
                  notifier.goBack();
                }
              } else {
                setState(() => _sectionIndex++);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              isLast
                  ? (hasQuiz ? 'Ir al Quiz →' : 'Completar lección')
                  : 'Siguiente →',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quiz ────────────────────────────────────────────────────────────────────

  Widget _buildQuiz(Lesson lesson, EducationNotifier notifier, Color color) {
    final allAnswered = _answers.every((a) => a != null);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '📝 Quiz — ${lesson.title}',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ...lesson.quiz.asMap().entries.map((entry) {
          final qi       = entry.key;
          final question = entry.value;
          return _QuizQuestionCard(
            question: question,
            questionIndex: qi,
            selectedAnswer: _answers[qi],
            submitted: false,
            color: color,
            onSelect: (optionIndex) {
              setState(() => _answers[qi] = optionIndex);
            },
          );
        }),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: allAnswered
              ? () {
                  setState(() => _submitted = true);
                  notifier.completeLesson(lesson.id, _correctCount);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allAnswered ? color : AppColors.border,
            foregroundColor:
                allAnswered ? Colors.white : AppColors.muted,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            'Ver resultados',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Resultados ──────────────────────────────────────────────────────────────

  Widget _buildResults(
      Lesson lesson, EducationNotifier notifier, Color color) {
    final correct = _correctCount;
    final total   = lesson.quiz.length;
    final pct     = total > 0 ? (correct / total * 100).round() : 100;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resultado general
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                pct >= 70 ? '🎉' : '📖',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                '$correct/$total respuestas correctas ($pct%)',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Feedback por pregunta
        ...lesson.quiz.asMap().entries.map((entry) {
          final qi       = entry.key;
          final question = entry.value;
          return _QuizQuestionCard(
            question: question,
            questionIndex: qi,
            selectedAnswer: _answers[qi],
            submitted: true,
            color: color,
            onSelect: (_) {},
          );
        }),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () => notifier.goBack(),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            '← Volver',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Quiz Question Card ────────────────────────────────────────────────────────

class _QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int questionIndex;
  final int? selectedAnswer;
  final bool submitted;
  final Color color;
  final ValueChanged<int> onSelect;

  const _QuizQuestionCard({
    required this.question,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.submitted,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${questionIndex + 1}. ${question.question}',
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ...question.options.asMap().entries.map((entry) {
            final oi     = entry.key;
            final option = entry.value;

            Color bgColor = AppColors.bg;
            Color borderColor = AppColors.border;
            Color textColor = AppColors.text;

            if (!submitted && selectedAnswer == oi) {
              bgColor = color.withValues(alpha: 0.15);
              borderColor = color;
              textColor = color;
            }

            if (submitted) {
              if (oi == question.correctIndex) {
                bgColor = AppColors.low.withValues(alpha: 0.12);
                borderColor = AppColors.low;
                textColor = AppColors.low;
              } else if (selectedAnswer == oi) {
                bgColor = AppColors.high.withValues(alpha: 0.12);
                borderColor = AppColors.high;
                textColor = AppColors.high;
              }
            }

            return GestureDetector(
              onTap: submitted ? null : () => onSelect(oi),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (submitted && oi == question.correctIndex)
                      const Icon(Icons.check_circle,
                          color: AppColors.low, size: 16)
                    else if (submitted && selectedAnswer == oi)
                      const Icon(Icons.cancel,
                          color: AppColors.high, size: 16),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── EVALUATION VIEW ──────────────────────────────────────────────────────────

class _EvaluationView extends ConsumerStatefulWidget {
  const _EvaluationView();

  @override
  ConsumerState<_EvaluationView> createState() => _EvaluationViewState();
}

class _EvaluationViewState extends ConsumerState<_EvaluationView> {
  // índice respuesta seleccionada por pregunta
  late List<int?> _answers;
  // cuál pregunta está "respondida" (se muestra feedback)
  late List<bool> _revealed;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _initAnswers();
  }

  void _initAnswers() {
    final mc = ref.read(educationProvider).activeMicrocourse;
    final count = mc?.evalQuestions.length ?? 0;
    _answers  = List.filled(count, null);
    _revealed = List.filled(count, false);
    _finished = false;
  }

  int get _totalXpEarned {
    final mc = ref.read(educationProvider).activeMicrocourse;
    if (mc == null) return 0;
    int total = 0;
    for (int i = 0; i < mc.evalQuestions.length; i++) {
      if (_answers[i] == mc.evalQuestions[i].correctIndex) {
        total += mc.evalQuestions[i].xp;
      }
    }
    return total;
  }

  int get _correctCount {
    final mc = ref.read(educationProvider).activeMicrocourse;
    if (mc == null) return 0;
    int count = 0;
    for (int i = 0; i < mc.evalQuestions.length; i++) {
      if (_answers[i] == mc.evalQuestions[i].correctIndex) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(educationProvider);
    final notifier = ref.read(educationProvider.notifier);
    final mc       = state.activeMicrocourse;

    if (mc == null) {
      return const Scaffold(
        body: Center(child: Text('Sin microcurso seleccionado')),
      );
    }

    final color = Color(mc.colorValue);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => notifier.goBack(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mc.evalTitle,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Text(
              'Evaluación final',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
      body: _finished
          ? _buildFinalResult(mc, notifier, color)
          : _buildEvaluation(mc, notifier, color),
    );
  }

  // ── Evaluación ──────────────────────────────────────────────────────────────

  Widget _buildEvaluation(
      Microcourse mc, EducationNotifier notifier, Color color) {
    final allAnswered = _answers.every((a) => a != null);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mc.evalDescription,
                style: const TextStyle(
                    color: AppColors.text, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _Chip(
                    label: '${mc.evalQuestions.length} preguntas',
                    color: color,
                  ),
                  _Chip(
                    label: 'Máx. ${mc.totalXp} XP',
                    color: AppColors.mid,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Preguntas
        ...mc.evalQuestions.asMap().entries.map((entry) {
          final qi       = entry.key;
          final question = entry.value;
          final answered = _revealed[qi];

          return _EvalQuestionCard(
            question: question,
            questionIndex: qi,
            selectedAnswer: _answers[qi],
            revealed: answered,
            color: color,
            onSelect: (optionIndex) {
              if (!answered) {
                setState(() {
                  _answers[qi]  = optionIndex;
                  _revealed[qi] = true;
                });
              }
            },
          );
        }),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: allAnswered
              ? () {
                  final xp = _totalXpEarned;
                  notifier.completeEvaluation(mc.id, xp);
                  setState(() => _finished = true);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allAnswered ? color : AppColors.border,
            foregroundColor:
                allAnswered ? Colors.white : AppColors.muted,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            'Ver resultado final',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Resultado final ─────────────────────────────────────────────────────────

  Widget _buildFinalResult(
      Microcourse mc, EducationNotifier notifier, Color color) {
    final correct = _correctCount;
    final total   = mc.evalQuestions.length;
    final xp      = _totalXpEarned;
    final pct     = total > 0 ? (correct / total * 100).round() : 0;
    final emoji   = pct >= 80 ? '🏆' : pct >= 50 ? '📊' : '📖';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resultado
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                '$correct/$total correctas ($pct%)',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.mid.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$xp XP ganados',
                  style: const TextStyle(
                    color: AppColors.mid,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${mc.badgeEmoji} ${mc.badgeName}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () => notifier.goBack(),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            '← Volver al módulo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Eval Question Card ────────────────────────────────────────────────────────

class _EvalQuestionCard extends StatelessWidget {
  final EvalQuestion question;
  final int questionIndex;
  final int? selectedAnswer;
  final bool revealed;
  final Color color;
  final ValueChanged<int> onSelect;

  const _EvalQuestionCard({
    required this.question,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.revealed,
    required this.color,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswer == question.correctIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: revealed
              ? (isCorrect
                  ? AppColors.low.withValues(alpha: 0.4)
                  : AppColors.high.withValues(alpha: 0.4))
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  '${questionIndex + 1}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.question,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (revealed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppColors.low.withValues(alpha: 0.12)
                        : AppColors.high.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isCorrect
                        ? '+${question.xp} XP'
                        : '+0 XP',
                    style: TextStyle(
                      color: isCorrect ? AppColors.low : AppColors.high,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Opciones
          ...question.options.asMap().entries.map((entry) {
            final oi     = entry.key;
            final option = entry.value;

            Color bgColor     = AppColors.bg;
            Color borderColor = AppColors.border;
            Color textColor   = AppColors.text;

            if (!revealed && selectedAnswer == oi) {
              bgColor     = color.withValues(alpha: 0.12);
              borderColor = color;
              textColor   = color;
            }

            if (revealed) {
              if (oi == question.correctIndex) {
                bgColor     = AppColors.low.withValues(alpha: 0.12);
                borderColor = AppColors.low;
                textColor   = AppColors.low;
              } else if (selectedAnswer == oi) {
                bgColor     = AppColors.high.withValues(alpha: 0.12);
                borderColor = AppColors.high;
                textColor   = AppColors.high;
              }
            }

            return GestureDetector(
              onTap: revealed ? null : () => onSelect(oi),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style:
                            TextStyle(color: textColor, fontSize: 13),
                      ),
                    ),
                    if (revealed && oi == question.correctIndex)
                      const Icon(Icons.check_circle,
                          color: AppColors.low, size: 16)
                    else if (revealed && selectedAnswer == oi)
                      const Icon(Icons.cancel,
                          color: AppColors.high, size: 16),
                  ],
                ),
              ),
            );
          }),

          // Explicación (solo cuando está respondida)
          if (revealed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ',
                      style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── CHIP HELPER ─────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
