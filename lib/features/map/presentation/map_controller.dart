import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/map_data.dart';

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState.initial());

  void setMunicipality(String name) {
    state = state.copyWith(
      selectedMunicipality: name,
      clearNeighborhood: true,
    );
  }

  void setNeighborhood(Neighborhood? neighborhood) {
    state = state.copyWith(selectedNeighborhood: neighborhood);
  }

  void clearNeighborhood() {
    state = state.copyWith(clearNeighborhood: true);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
