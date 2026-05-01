import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int selectedMunicipalityIndex;

  HomeState({
    this.selectedMunicipalityIndex = 0,
  });

  HomeState copyWith({
    int? selectedMunicipalityIndex,
  }) {
    return HomeState(
      selectedMunicipalityIndex: selectedMunicipalityIndex ?? this.selectedMunicipalityIndex,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());

  void setMunicipalityIndex(int index) {
    state = state.copyWith(selectedMunicipalityIndex: index);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
