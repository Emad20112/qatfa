import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/mock_qatfa_data.dart';

// -----------------------------------------------------------------------------
// الأحداث والحالات
// -----------------------------------------------------------------------------
class CitySelectorEvent extends Equatable {
  final String city;

  const CitySelectorEvent(this.city);

  @override
  List<Object?> get props => [city];
}

class CitySelectorState extends Equatable {
  final String currentCity;
  final List<String> availableCities;

  const CitySelectorState({
    this.currentCity = 'صنعاء',
    this.availableCities = MockQatfaData.cities,
  });

  CitySelectorState copyWith({
    String? currentCity,
    List<String>? availableCities,
  }) {
    return CitySelectorState(
      currentCity: currentCity ?? this.currentCity,
      availableCities: availableCities ?? this.availableCities,
    );
  }

  @override
  List<Object?> get props => [currentCity, availableCities];
}

// -----------------------------------------------------------------------------
// الـ BLoC
// -----------------------------------------------------------------------------
class CitySelectorBloc extends Bloc<CitySelectorEvent, CitySelectorState> {
  static const String _prefKey = 'selected_city_preference';

  CitySelectorBloc() : super(const CitySelectorState()) {
    on<CitySelectorEvent>(_onSelectCity);
    _loadSavedCity();
  }

  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && saved.isNotEmpty) {
        add(CitySelectorEvent(saved));
      }
    } catch (_) {}
  }

  Future<void> _onSelectCity(
    CitySelectorEvent event,
    Emitter<CitySelectorState> emit,
  ) async {
    emit(state.copyWith(currentCity: event.city));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, event.city);
    } catch (_) {}
  }
}
