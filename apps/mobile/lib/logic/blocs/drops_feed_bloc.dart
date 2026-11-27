import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../data/models/qatfa_models.dart';
import '../../data/repositories/drops_repository_impl.dart';

// -----------------------------------------------------------------------------
// الأحداث (Events)
// -----------------------------------------------------------------------------
sealed class DropsFeedEvent extends Equatable {
  const DropsFeedEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDropsFeed extends DropsFeedEvent {
  final String? city;
  final String? qatType;
  final bool isRefresh;

  const LoadDropsFeed({this.city, this.qatType, this.isRefresh = false});

  @override
  List<Object?> get props => [city, qatType, isRefresh];
}

final class FilterByQatType extends DropsFeedEvent {
  final String qatType;

  const FilterByQatType(this.qatType);

  @override
  List<Object?> get props => [qatType];
}

final class LoadMoreDrops extends DropsFeedEvent {
  const LoadMoreDrops();
}

// -----------------------------------------------------------------------------
// الحالات (States)
// -----------------------------------------------------------------------------
sealed class DropsFeedState extends Equatable {
  const DropsFeedState();

  @override
  List<Object?> get props => [];
}

final class DropsFeedInitial extends DropsFeedState {}

final class DropsFeedLoading extends DropsFeedState {}

final class DropsFeedLoaded extends DropsFeedState {
  final List<DropItem> drops;
  final String selectedCity;
  final String selectedType;
  final bool hasReachedMax;

  const DropsFeedLoaded({
    required this.drops,
    this.selectedCity = 'صنعاء',
    this.selectedType = 'الكل',
    this.hasReachedMax = false,
  });

  DropsFeedLoaded copyWith({
    List<DropItem>? drops,
    String? selectedCity,
    String? selectedType,
    bool? hasReachedMax,
  }) {
    return DropsFeedLoaded(
      drops: drops ?? this.drops,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedType: selectedType ?? this.selectedType,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [drops, selectedCity, selectedType, hasReachedMax];
}

final class DropsFeedError extends DropsFeedState {
  final String message;

  const DropsFeedError(this.message);

  @override
  List<Object?> get props => [message];
}

// -----------------------------------------------------------------------------
// الـ BLoC
// -----------------------------------------------------------------------------
class DropsFeedBloc extends Bloc<DropsFeedEvent, DropsFeedState> {
  final IDropsRepository _repository;

  DropsFeedBloc({IDropsRepository? repository})
      : _repository = repository ?? DropsRepositoryImpl(),
        super(DropsFeedInitial()) {
    on<LoadDropsFeed>(_onLoadDropsFeed);
    on<FilterByQatType>(_onFilterByQatType);
    // منع تكرار طلبات التمرير اللانهائي عبر محول droppable
    on<LoadMoreDrops>(_onLoadMoreDrops, transformer: droppable());
  }

  Future<void> _onLoadDropsFeed(
    LoadDropsFeed event,
    Emitter<DropsFeedState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(DropsFeedLoading());
    }

    try {
      final city = event.city ?? (state is DropsFeedLoaded ? (state as DropsFeedLoaded).selectedCity : 'صنعاء');
      final type = event.qatType ?? (state is DropsFeedLoaded ? (state as DropsFeedLoaded).selectedType : 'الكل');

      final drops = await _repository.getDailyDrops(
        city: city,
        qatType: type,
        page: 1,
      );

      emit(DropsFeedLoaded(
        drops: drops,
        selectedCity: city,
        selectedType: type,
        hasReachedMax: drops.length < 20,
      ));
    } catch (e) {
      emit(DropsFeedError('تعذر جلب عروض اليوم: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByQatType(
    FilterByQatType event,
    Emitter<DropsFeedState> emit,
  ) async {
    final currentCity = state is DropsFeedLoaded ? (state as DropsFeedLoaded).selectedCity : 'صنعاء';
    emit(DropsFeedLoading());
    try {
      final drops = await _repository.getDailyDrops(
        city: currentCity,
        qatType: event.qatType,
        page: 1,
      );
      emit(DropsFeedLoaded(
        drops: drops,
        selectedCity: currentCity,
        selectedType: event.qatType,
        hasReachedMax: true,
      ));
    } catch (e) {
      emit(DropsFeedError(e.toString()));
    }
  }

  Future<void> _onLoadMoreDrops(
    LoadMoreDrops event,
    Emitter<DropsFeedState> emit,
  ) async {
    if (state is! DropsFeedLoaded) return;
    final currentState = state as DropsFeedLoaded;
    if (currentState.hasReachedMax) return;

    try {
      final moreDrops = await _repository.getDailyDrops(
        city: currentState.selectedCity,
        qatType: currentState.selectedType,
        page: (currentState.drops.length ~/ 20) + 1,
      );

      if (moreDrops.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        emit(currentState.copyWith(
          drops: List.of(currentState.drops)..addAll(moreDrops),
          hasReachedMax: moreDrops.length < 20,
        ));
      }
    } catch (_) {
      // الحفاظ على الحالة السابقة عند الفشل
    }
  }
}
