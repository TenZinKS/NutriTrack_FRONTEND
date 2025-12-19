import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final bool isCritical;
  final DateTime scheduledAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.scheduledAt,
    this.isCritical = false,
  });

  @override
  List<Object?> get props => [id, title, message, timeLabel, isCritical, scheduledAt];
}
