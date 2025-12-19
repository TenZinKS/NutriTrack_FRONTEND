import '../entities/reminder.dart';
import '../entities/user_macros.dart';

class GenerateRemindersUsecase {
  List<Reminder> call(UserMacros macros) {
    final reminders = <Reminder>[];
    final now = DateTime.now();
    DateTime scheduledAtForOffset(int hoursFromNow) {
      return now.add(Duration(hours: hoursFromNow));
    }

    String timeLabelFor(DateTime dateTime) {
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minutes = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minutes $period';
    }

    final caloriesProgress = macros.caloriesGoal == 0
        ? 0.0
        : macros.caloriesConsumed / macros.caloriesGoal;
    if (caloriesProgress < 0.4) {
      final scheduledAt = scheduledAtForOffset(1);
      reminders.add(
        Reminder(
          id: 'log_meal',
          title: 'Log a meal',
          message: 'You have logged less than half of your calories. Capture lunch or a snack.',
          timeLabel: timeLabelFor(scheduledAt),
          scheduledAt: scheduledAt,
        ),
      );
    }

    final proteinProgress = macros.proteinGoal == 0
        ? 0.0
        : macros.proteinConsumed / macros.proteinGoal;
    if (proteinProgress < 0.5) {
      final scheduledAt = scheduledAtForOffset(2);
      reminders.add(
        Reminder(
          id: 'protein_push',
          title: 'Boost your protein',
          message: 'Add a lean protein serving to stay on track with your goal.',
          timeLabel: timeLabelFor(scheduledAt),
          scheduledAt: scheduledAt,
        ),
      );
    }

    final waterProgress = macros.waterGoal == 0
        ? 0.0
        : macros.waterConsumed / macros.waterGoal;
    if (waterProgress < 0.5) {
      final scheduledAt = scheduledAtForOffset(0);
      reminders.add(
        Reminder(
          id: 'hydrate',
          title: 'Hydration break',
          message: 'Drink a glass of water to hit your hydration target.',
          timeLabel: timeLabelFor(scheduledAt),
          scheduledAt: scheduledAt,
        ),
      );
    }

    if (caloriesProgress > 1.0) {
      final scheduledAt = scheduledAtForOffset(3);
      reminders.add(
        Reminder(
          id: 'calorie_over',
          title: 'Calories exceeded',
          message: 'Plan a lighter dinner or go for a walk to balance the day.',
          timeLabel: timeLabelFor(scheduledAt),
          scheduledAt: scheduledAt,
          isCritical: true,
        ),
      );
    }

    if (reminders.isEmpty) {
      final scheduledAt = scheduledAtForOffset(4);
      reminders.add(
        Reminder(
          id: 'keep_up',
          title: 'Great consistency',
          message: 'Keep logging meals to maintain your streak.',
          timeLabel: timeLabelFor(scheduledAt),
          scheduledAt: scheduledAt,
        ),
      );
    }

    return reminders;
  }
}
