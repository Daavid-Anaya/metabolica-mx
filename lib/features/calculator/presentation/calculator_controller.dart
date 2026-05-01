import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/iarri_logic.dart';
import '../../home/presentation/main_shell.dart';

class CalculatorState {
  final Map<String, double> iarriValues;
  final Map<String, double> iarmValues;
  final int activeTab;
  final List<double>? simulationResults;
  final bool isSimulating;
  final bool isSaving;

  CalculatorState({
    required this.iarriValues,
    required this.iarmValues,
    this.activeTab = 0,
    this.simulationResults,
    this.isSimulating = false,
    this.isSaving = false,
  });

  factory CalculatorState.initial() {
    return CalculatorState(
      iarriValues: {
        'AV': 0.80,
        'IC': 0.60,
        'ED': 0.40,
        'EAR': 0.45,
        'IMP': 0.10,
      },
      iarmValues: {
        'ST': 0.50,
        'BAV': 0.50,
        'DEN': 0.50,
        'BEA': 0.50,
      },
    );
  }

  CalculatorState copyWith({
    Map<String, double>? iarriValues,
    Map<String, double>? iarmValues,
    int? activeTab,
    List<double>? simulationResults,
    bool? isSimulating,
    bool? isSaving,
  }) {
    return CalculatorState(
      iarriValues: iarriValues ?? this.iarriValues,
      iarmValues: iarmValues ?? this.iarmValues,
      activeTab: activeTab ?? this.activeTab,
      simulationResults: simulationResults ?? this.simulationResults,
      isSimulating: isSimulating ?? this.isSimulating,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final Ref _ref;
  CalculatorNotifier(this._ref) : super(CalculatorState.initial());

  void setIarriValue(String key, double value) {
    final newValues = Map<String, double>.from(state.iarriValues);
    newValues[key] = value;
    state = state.copyWith(iarriValues: newValues, simulationResults: null);
  }

  void setIarmValue(String key, double value) {
    final newValues = Map<String, double>.from(state.iarmValues);
    newValues[key] = value;
    state = state.copyWith(iarmValues: newValues);
  }

  void setTab(int index) {
    state = state.copyWith(activeTab: index);
  }

  void setPreset(Map<String, double> values) {
    state = state.copyWith(iarriValues: values, simulationResults: null);
  }

  Future<void> runSimulation() async {
    state = state.copyWith(isSimulating: true);
    
    // Simulating heavy computation
    await Future.delayed(const Duration(milliseconds: 800));
    
    final results = IARRILogic.monteCarloSimulation(
      variables: state.iarriValues,
      n: 1000,
    );
    
    state = state.copyWith(
      simulationResults: results,
      isSimulating: false,
    );
  }

  Future<void> saveResult() async {
    state = state.copyWith(isSaving: true);
    
    // TODO: Real Supabase persistence
    await Future.delayed(const Duration(seconds: 1));
    
    state = state.copyWith(isSaving: false);
    
    // Auto-navigate to Intervención tab (index 3)
    _ref.read(navigationProvider.notifier).state = 3;
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier(ref);
});
