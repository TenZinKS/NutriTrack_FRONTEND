import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/nutri_bottom_nav_bar.dart';
import '../../../analysis/presentation/pages/analysis_page.dart';
import '../../../meal_planner/presentation/pages/ai_meal_planner_page.dart';
import '../../../my_foods/presentation/pages/my_foods_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/user_macros.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/listen_user_macros_usecase.dart';
import '../../domain/usecases/update_user_macros_usecase.dart';
import '../../domain/usecases/generate_reminders_usecase.dart';
import '../../../../core/notifications/notification_service.dart';
import '../bloc/macros_bloc.dart';
import '../bloc/macros_event.dart';
import '../bloc/macros_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final GenerateRemindersUsecase _generateRemindersUsecase;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _generateRemindersUsecase = sl();
    _notificationService = sl();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MacrosBloc(
        listenUserMacrosUsecase: sl<ListenUserMacrosUsecase>(),
        updateUserMacrosUsecase: sl<UpdateUserMacrosUsecase>(),
      )..add(LoadMacrosEvent()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<MacrosBloc, MacrosState>(
            builder: (context, state) {
              if (state.status == MacrosStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == MacrosStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message ?? 'Something went wrong',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<MacrosBloc>().add(LoadMacrosEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final macros = state.macros;
              final caloriesDiff = macros.caloriesGoal - macros.caloriesConsumed;
              final caloriesLeft = caloriesDiff < 0 ? 0 : caloriesDiff;
              final caloriesProgress = macros.caloriesGoal == 0
                  ? 0.0
                  : (macros.caloriesConsumed / macros.caloriesGoal)
                      .clamp(0, 1)
                      .toDouble();
              final reminders = _generateRemindersUsecase(macros);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _notificationService.syncReminders(reminders),
              );

              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF080808), Color(0xFF111111)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildGreetingHeader(context, macros, reminders),
                            const SizedBox(height: 20),
                            _buildCaloriesGauge(
                              caloriesLeft,
                              macros.caloriesGoal,
                              caloriesProgress,
                              macros.caloriesConsumed,
                            ),
                            const SizedBox(height: 28),
                            _buildMacroGrid(context, macros),
                            const SizedBox(height: 28),
                            if (reminders.isNotEmpty) _buildRemindersCard(context, reminders),
                            if (reminders.isNotEmpty) const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatWeekday() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[(now.weekday - 1).clamp(0, weekdays.length - 1)];
  }

  Widget _buildCaloriesGauge(
    int caloriesLeft,
    int caloriesGoal,
    double progress,
    int consumed,
  ) {
    final hasExceeded = consumed > caloriesGoal;
    final displayLeft = hasExceeded ? consumed - caloriesGoal : caloriesLeft;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, _) {
                    return CustomPaint(
                      size: const Size(220, 110),
                      painter: _SemiCirclePainter(
                        progress: value,
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: hasExceeded ? Colors.redAccent : Colors.white,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 48,
                  child: Column(
                    children: [
                      Text(
                        '$displayLeft',
                        style: TextStyle(
                          color: hasExceeded ? Colors.redAccent : Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasExceeded ? 'Over' : 'Left',
                        style: TextStyle(color: hasExceeded ? Colors.redAccent : Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Calories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasExceeded)
            const Text(
              'Calorie goal exceeded',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              '$consumed consumed of $caloriesGoal kcal',
              style: const TextStyle(color: Colors.white60),
            ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(
    BuildContext context,
    UserMacros macros,
    List<Reminder> reminders,
  ) {
    final hasCritical = reminders.any((reminder) => reminder.isCritical);
    final firstName = (macros.name.isEmpty ? 'there' : macros.name).split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hi $firstName!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Today is ${_formatWeekday()}",
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showRemindersSheet(context, reminders),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              if (hasCritical)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroGrid(BuildContext blocContext, UserMacros macros) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 0.85,
      children: [
        _buildMacroCard(
          title: 'Carbs',
          consumed: macros.carbsConsumed,
          goal: macros.carbsGoal,
          color: const Color(0xFFE8FF73),
          icon: Icons.rice_bowl,
        ),
        _buildMacroCard(
          title: 'Protein',
          consumed: macros.proteinConsumed,
          goal: macros.proteinGoal,
          color: const Color(0xFF28D8D8),
          icon: Icons.egg_alt,
        ),
        _buildMacroCard(
          title: 'Fat',
          consumed: macros.fatConsumed,
          goal: macros.fatGoal,
          color: const Color(0xFFFF8A34),
          icon: Icons.invert_colors,
        ),
        _buildMacroCard(
          title: 'Water',
          consumed: macros.waterConsumed,
          goal: macros.waterGoal,
          color: const Color(0xFF00B1FF),
          icon: Icons.local_drink,
          unit: 'ml',
          onTap: () => _showWaterEntryDialog(blocContext, macros),
          showMenuIcon: true,
        ),
      ],
    );
  }

  Widget _buildMacroCard({
    required String title,
    required int consumed,
    required int goal,
    required Color color,
    required IconData icon,
    String unit = 'g',
    VoidCallback? onTap,
    bool showMenuIcon = false,
  }) {
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0, 1).toDouble();
    final hasExceeded = consumed > goal;
    final backgroundColor = hasExceeded ? Colors.redAccent : color;
    final textColor = hasExceeded ? Colors.white : Colors.black;
    final detailTextColor = hasExceeded ? Colors.white70 : Colors.black54;
    final warningTextColor = hasExceeded ? Colors.white : Colors.black87;
    final card = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.black87),
              ),
              if (showMenuIcon) const Icon(Icons.more_horiz, color: Colors.black45),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black12,
            color: hasExceeded ? Colors.white : Colors.black87,
            minHeight: 6,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$consumed$unit',
                style: TextStyle(
                  color: warningTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$goal$unit',
                style: TextStyle(color: detailTextColor),
              ),
            ],
          ),
          if (hasExceeded) ...[
            const SizedBox(height: 8),
            Text(
              'Exceeded',
              style: TextStyle(
                color: warningTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return NutriBottomNavBar(
      selectedIndex: 0,
      onAddTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AiMealPlannerPage()),
        );
      },
      onItemSelected: (index) {
        if (index == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AnalysisPage()),
          );
        } else if (index == 3) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MyFoodsPage()),
          );
        } else if (index == 4) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        }
      },
    );
  }

  Future<void> _showUpdateMacrosSheet(BuildContext context, UserMacros macros) async {
    final controllers = <String, TextEditingController>{
      'caloriesGoal': TextEditingController(text: macros.caloriesGoal.toString()),
      'caloriesConsumed': TextEditingController(text: macros.caloriesConsumed.toString()),
      'carbsGoal': TextEditingController(text: macros.carbsGoal.toString()),
      'carbsConsumed': TextEditingController(text: macros.carbsConsumed.toString()),
      'proteinGoal': TextEditingController(text: macros.proteinGoal.toString()),
      'proteinConsumed': TextEditingController(text: macros.proteinConsumed.toString()),
      'fatGoal': TextEditingController(text: macros.fatGoal.toString()),
      'fatConsumed': TextEditingController(text: macros.fatConsumed.toString()),
      'waterGoal': TextEditingController(text: macros.waterGoal.toString()),
      'waterConsumed': TextEditingController(text: macros.waterConsumed.toString()),
    };

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Macros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetField('Calories Goal', controllers['caloriesGoal']!),
                _sheetField('Calories Consumed', controllers['caloriesConsumed']!),
                _sheetField('Carbs Goal', controllers['carbsGoal']!),
                _sheetField('Carbs Consumed', controllers['carbsConsumed']!),
                _sheetField('Protein Goal', controllers['proteinGoal']!),
                _sheetField('Protein Consumed', controllers['proteinConsumed']!),
                _sheetField('Fat Goal', controllers['fatGoal']!),
                _sheetField('Fat Consumed', controllers['fatConsumed']!),
                _sheetField('Water Goal (ml)', controllers['waterGoal']!),
                _sheetField('Water Consumed (ml)', controllers['waterConsumed']!),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = macros.copyWith(
                        caloriesGoal: int.tryParse(controllers['caloriesGoal']!.text) ??
                            macros.caloriesGoal,
                        caloriesConsumed:
                            int.tryParse(controllers['caloriesConsumed']!.text) ??
                                macros.caloriesConsumed,
                        carbsGoal: int.tryParse(controllers['carbsGoal']!.text) ?? macros.carbsGoal,
                        carbsConsumed:
                            int.tryParse(controllers['carbsConsumed']!.text) ?? macros.carbsConsumed,
                        proteinGoal: int.tryParse(controllers['proteinGoal']!.text) ??
                            macros.proteinGoal,
                        proteinConsumed:
                            int.tryParse(controllers['proteinConsumed']!.text) ??
                                macros.proteinConsumed,
                        fatGoal: int.tryParse(controllers['fatGoal']!.text) ?? macros.fatGoal,
                        fatConsumed:
                            int.tryParse(controllers['fatConsumed']!.text) ?? macros.fatConsumed,
                        waterGoal: int.tryParse(controllers['waterGoal']!.text) ?? macros.waterGoal,
                        waterConsumed:
                            int.tryParse(controllers['waterConsumed']!.text) ??
                                macros.waterConsumed,
                      );
                      Navigator.of(sheetContext).pop();
                      this.context
                          .read<MacrosBloc>()
                          .add(SubmitMacrosUpdateEvent(updated));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _showWaterEntryDialog(BuildContext context, UserMacros macros) async {
    final bloc = context.read<MacrosBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
    final WaterAction? action = await showDialog<WaterAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101010),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Water',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount (ml)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.green),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text);
                if (parsed == null || parsed <= 0) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(WaterAction.remove(parsed));
              },
              child: const Text('Remove'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text);
                if (parsed == null || parsed <= 0) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(WaterAction.add(parsed));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (action == null || action.amount <= 0) return;

    final delta = action.type == WaterActionType.add ? action.amount : -action.amount;
    final updated = macros.copyWith(
      waterConsumed: (macros.waterConsumed + delta).clamp(0, 100000),
    );
    if (!mounted) return;
    bloc.add(SubmitMacrosUpdateEvent(updated));
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: reminder.isCritical ? Colors.redAccent.withOpacity(0.12) : const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reminder.isCritical ? Colors.redAccent.withOpacity(0.4) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            reminder.isCritical ? Icons.warning_amber_rounded : Icons.alarm,
            color: reminder.isCritical ? Colors.redAccent : Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            reminder.timeLabel,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

enum WaterActionType { add, remove }

class WaterAction {
  final WaterActionType type;
  final int amount;

  const WaterAction(this.type, this.amount);

  factory WaterAction.add(int amount) => WaterAction(WaterActionType.add, amount);
  factory WaterAction.remove(int amount) => WaterAction(WaterActionType.remove, amount);
}

class _SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;

  _SemiCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    final foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..color = foregroundColor;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.foregroundColor != foregroundColor;
  }
}
  Widget _buildRemindersCard(BuildContext context, List<Reminder> reminders) {
    final preview = reminders.take(3).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Reminders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showRemindersSheet(context, reminders),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...preview.map((reminder) => _ReminderTile(reminder: reminder)),
        ],
      ),
    );
  }

  void _showRemindersSheet(BuildContext context, List<Reminder> reminders) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...reminders.map((reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReminderTile(reminder: reminder),
                  )),
            ],
          ),
        );
      },
    );
  }
