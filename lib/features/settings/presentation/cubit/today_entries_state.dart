part of 'today_entries_cubit.dart';

enum TodayEntriesStatus { initial, loading, success, failure }

class TodayEntriesState {
  final TodayEntriesStatus status;
  final List<FoodEntry> entries;
  final bool actionInProgress;
  final String? message;

  const TodayEntriesState({
    this.status = TodayEntriesStatus.initial,
    this.entries = const [],
    this.actionInProgress = false,
    this.message,
  });

  TodayEntriesState copyWith({
    TodayEntriesStatus? status,
    List<FoodEntry>? entries,
    bool? actionInProgress,
    String? message,
  }) {
    return TodayEntriesState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      message: message,
    );
  }
}
