import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../domain/test_questions.dart';
import 'test_controller.dart';

class TestView extends ConsumerWidget {
  const TestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testProvider);
    final notifier = ref.read(testProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Síntomas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.accent),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(state),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ..._buildQuestionList(state, notifier),
                  const SizedBox(height: 24),
                  if (!state.showResults)
                    ElevatedButton.icon(
                      onPressed: notifier.submit,
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: const Text('Ver mi resultado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (state.showResults) _buildResults(state, notifier),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TestState state) {
    final progress = state.answeredCount / testQuestions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test de Síntomas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const Text(
                    'Resistencia a la Insulina',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Responde Sí o No a cada pregunta. Al terminar verás tu resultado automáticamente.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.answeredCount} de ${testQuestions.length} respondidas',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionList(TestState state, TestNotifier notifier) {
    final widgets = <Widget>[];
    String? lastCategory;

    for (var i = 0; i < testQuestions.length; i++) {
      final q = testQuestions[i];
      if (q.category != lastCategory) {
        lastCategory = q.category;
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildCategoryTitle(q.category.toUpperCase()));
        widgets.add(const SizedBox(height: 8));
      }

      final isAnswered = state.answers[i] != null;
      final answer = state.answers[i];
      final isPending = state.highlightPending && !isAnswered;

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPending ? AppColors.high.withValues(alpha: 0.6) : AppColors.border,
              width: isPending ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}. ${q.text}',
                style: const TextStyle(fontSize: 13, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildAnswerButton(
                    text: q.yesResponse,
                    isSelected: answer == true,
                    onTap: () => notifier.setAnswer(i, true),
                    activeColor: AppColors.accent,
                  ),
                  const SizedBox(height: 8),
                  _buildAnswerButton(
                    text: q.noResponse,
                    isSelected: answer == false,
                    onTap: () => notifier.setAnswer(i, false),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildCategoryTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? activeColor : AppColors.text,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(TestState state, TestNotifier notifier) {
    String nivel;
    Color color;
    String emoji;
    String desc;

    if (state.yesCount <= 3) {
      nivel = "Bajo riesgo";
      color = AppColors.low;
      emoji = "✅";
      desc = "Tu perfil no muestra señales significativas de resistencia a la insulina. Mantén tus hábitos saludables.";
    } else if (state.yesCount <= 7) {
      nivel = "Riesgo moderado";
      color = AppColors.mid;
      emoji = "⚠️";
      desc = "Tienes algunos indicadores de riesgo. Te recomendamos mejorar hábitos de alimentación y actividad física.";
    } else {
      nivel = "Alto riesgo";
      color = AppColors.high;
      emoji = "🔴";
      desc = "Presentas varios indicadores de resistencia a la insulina. Consulta a un médico y solicita estudios de glucosa e insulina en ayuno.";
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nivel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                      Text('${state.yesCount} de ${testQuestions.length} síntomas presentes', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.text)),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              const Text("Pruebas médicas recomendadas", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent)),
              const SizedBox(height: 4),
              const Text("• Glucosa en ayuno\n• Insulina en ayuno\n• Índice HOMA-IR\n• Hemoglobina glucosilada (HbA1c)", style: TextStyle(fontSize: 12, color: AppColors.text)),
              const SizedBox(height: 16),
              const Text("💡 Consejo clave", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mid)),
              const SizedBox(height: 4),
              const Text("La resistencia a la insulina es reversible en muchos casos con cambios constantes (no extremos).", style: TextStyle(fontSize: 12, color: AppColors.text)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: notifier.reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Hacer el test de nuevo"),
        ),
      ],
    );
  }
}
