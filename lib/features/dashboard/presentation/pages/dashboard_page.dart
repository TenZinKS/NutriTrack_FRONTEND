import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/user_macros.dart';
import '../../domain/usecases/listen_user_macros_usecase.dart';
import '../../domain/usecases/update_user_macros_usecase.dart';
import '../bloc/macros_bloc.dart';
import '../bloc/macros_event.dart';
import '../bloc/macros_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Hi ${macros.name.isEmpty ? 'there' : macros.name}!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Today is ${_formatWeekday()}",
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildCaloriesGauge(
                              caloriesLeft,
                              macros.caloriesGoal,
                              caloriesProgress,
                              macros.caloriesConsumed,
                            ),
                            const SizedBox(height: 28),
                            _buildMacroGrid(macros),
                            const SizedBox(height: 28)
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(context, macros),
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
                        foregroundColor: Colors.white,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 48,
                  child: Column(
                    children: [
                      Text(
                        '$caloriesLeft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Left',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('0', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      SizedBox(height: 2),
                      Text('Consumed', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$caloriesGoal', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 2),
                      const Text('Goal', style: TextStyle(color: Colors.white38, fontSize: 11)),
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
          Text(
            '$consumed consumed of $caloriesGoal kcal',
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroGrid(UserMacros macros) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 1.05,
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
  }) {
    final progress = goal == 0 ? 0.0 : (consumed / goal).clamp(0, 1).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
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
              const Icon(Icons.more_horiz, color: Colors.black45),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black12,
            color: Colors.black87,
            minHeight: 6,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$consumed$unit',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$goal$unit',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, UserMacros macros) {
    final isUpdating = context.watch<MacrosBloc>().state.status == MacrosStatus.updating;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bottomNavIcon(Icons.home_filled, isActive: true),
            _bottomNavIcon(Icons.show_chart),
            GestureDetector(
              onTap: isUpdating ? null : () => _showUpdateMacrosSheet(context, macros),
              child: _bottomNavIcon(
                Icons.add,
                highlight: true,
                disabled: isUpdating,
              ),
            ),
            _bottomNavIcon(Icons.restaurant_menu),
            _bottomNavIcon(Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavIcon(
    IconData icon, {
    bool isActive = false,
    bool highlight = false,
    bool disabled = false,
  }) {
    final color = highlight
        ? (disabled ? Colors.white70 : Colors.black)
        : isActive
            ? Colors.green
            : Colors.white70;
    final background = highlight
        ? (disabled ? Colors.green.withOpacity(0.4) : Colors.white)
        : Colors.transparent;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: highlight
            ? null
            : Border.all(
                color: isActive ? Colors.green : Colors.white24,
                width: isActive ? 2 : 1,
              ),
      ),
      child: Icon(icon, color: color),
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
