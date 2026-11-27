import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/qatfa_models.dart';
import '../../data/repositories/markets_repository_impl.dart';

// -----------------------------------------------------------------------------
// الأحداث (Events)
// -----------------------------------------------------------------------------
sealed class MarketsEvent extends Equatable {
  const MarketsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadMarkets extends MarketsEvent {
  final String? city;

  const LoadMarkets({this.city});

  @override
  List<Object?> get props => [city];
}

final class SelectMarketStalls extends MarketsEvent {
  final String marketId;

  const SelectMarketStalls(this.marketId);

  @override
  List<Object?> get props => [marketId];
}

// -----------------------------------------------------------------------------
// الحالات (States)
// -----------------------------------------------------------------------------
sealed class MarketsState extends Equatable {
  const MarketsState();

  @override
  List<Object?> get props => [];
}

final class MarketsInitial extends MarketsState {}

final class MarketsLoading extends MarketsState {}

final class MarketsLoaded extends MarketsState {
  final List<MarketItem> markets;
  final String selectedCity;
  final List<StallItem> stalls;
  final String? selectedMarketId;

  const MarketsLoaded({
    required this.markets,
    this.selectedCity = 'صنعاء',
    this.stalls = const [],
    this.selectedMarketId,
  });

  MarketsLoaded copyWith({
    List<MarketItem>? markets,
    String? selectedCity,
    List<StallItem>? stalls,
    String? selectedMarketId,
  }) {
    return MarketsLoaded(
      markets: markets ?? this.markets,
      selectedCity: selectedCity ?? this.selectedCity,
      stalls: stalls ?? this.stalls,
      selectedMarketId: selectedMarketId ?? this.selectedMarketId,
    );
  }

  @override
  List<Object?> get props => [markets, selectedCity, stalls, selectedMarketId];
}

final class MarketsError extends MarketsState {
  final String message;

  const MarketsError(this.message);

  @override
  List<Object?> get props => [message];
}

// -----------------------------------------------------------------------------
// الـ BLoC
// -----------------------------------------------------------------------------
class MarketsBloc extends Bloc<MarketsEvent, MarketsState> {
  final IMarketsRepository _repository;

  MarketsBloc({IMarketsRepository? repository})
      : _repository = repository ?? MarketsRepositoryImpl(),
        super(MarketsInitial()) {
    on<LoadMarkets>(_onLoadMarkets);
    on<SelectMarketStalls>(_onSelectMarketStalls);
  }

  Future<void> _onLoadMarkets(
    LoadMarkets event,
    Emitter<MarketsState> emit,
  ) async {
    emit(MarketsLoading());
    try {
      final city = event.city ?? 'صنعاء';
      final markets = await _repository.getMarkets(city: city);
      final firstMarketId = markets.isNotEmpty ? markets.first.id : 'm_1';
      final stalls = await _repository.getStallsByMarket(firstMarketId);

      emit(MarketsLoaded(
        markets: markets,
        selectedCity: city,
        stalls: stalls,
        selectedMarketId: firstMarketId,
      ));
    } catch (e) {
      emit(MarketsError('تعذر جلب قائمة الأسواق: ${e.toString()}'));
    }
  }

  Future<void> _onSelectMarketStalls(
    SelectMarketStalls event,
    Emitter<MarketsState> emit,
  ) async {
    if (state is! MarketsLoaded) return;
    final currentState = state as MarketsLoaded;

    try {
      final stalls = await _repository.getStallsByMarket(event.marketId);
      emit(currentState.copyWith(
        selectedMarketId: event.marketId,
        stalls: stalls,
      ));
    } catch (_) {}
  }
}
