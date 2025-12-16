import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/nutri_bottom_nav_bar.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../meal_planner/presentation/pages/ai_meal_planner_page.dart';
import '../../../my_foods/presentation/pages/my_foods_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/analysis_range.dart';
import '../bloc/analysis_cubit.dart';
import '../bloc/analysis_state.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AnalysisCubit(getAnalysisRangeUsecase: sl())..loadRange('daily'),
      child: const _AnalysisView(),
    );
  }
}

class _AnalysisView extends StatelessWidget {
  const _AnalysisView();

  static const _rangeLabels = ['Daily', 'Weekly', 'Monthly'];
  static const _rangeKeys = ['daily', 'weekly', 'monthly'];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisCubit, AnalysisState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: _buildContent(context, state)),
                NutriBottomNavBar(
                  selectedIndex: 1,
                  onItemSelected: (index) {
                    if (index == 0) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
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
                  onAddTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiMealPlannerPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AnalysisState state) {
    switch (state.status) {
      case AnalysisStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AnalysisStatus.failure:
        return _buildError(context, state.message);
      case AnalysisStatus.success:
      case AnalysisStatus.initial:
        return _buildSuccess(context, state);
    }
  }

  Widget _buildError(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? 'Unable to load analysis',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<AnalysisCubit>().loadRange('daily'),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, AnalysisState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildHeroCard(),
          const SizedBox(height: 24),
          _buildRangeSelector(context, state),
          const SizedBox(height: 20),
          _buildCalorieTrends(state.data),
          const SizedBox(height: 20),
          _buildMacroDistribution(state.data),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF20C86B),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Nutrition Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track trends. Spot patterns. Crush your goals.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context, AnalysisState state) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: List.generate(_rangeLabels.length, (index) {
          final isSelected = state.range == _rangeKeys[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<AnalysisCubit>().loadRange(_rangeKeys[index]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF6C2F) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  _rangeLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalorieTrends(AnalysisRange data) {
    const labelStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );
    final actual = data.underGoalTrend;
    final goal = data.overGoalTrend;
    final labels = data.labels.isEmpty ? _rangeLabels : data.labels;
    final avg = actual.isEmpty ? 0 : actual.reduce((a, b) => a + b) / actual.length;
    final bestDayIndex = _minIndex(actual);
    final worstDayIndex = _maxIndex(actual);
    final bestValue = actual.isEmpty ? 0 : actual[bestDayIndex];
    final worstValue = actual.isEmpty ? 0 : actual[worstDayIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE2C7FF),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calorie Trends', style: labelStyle),
          const SizedBox(height: 12),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFEDD8FF),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: LineChart(
              _buildLineChartData(actual, goal, labels),
              duration: const Duration(milliseconds: 350),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _LegendDot(
                color: const Color(0xFFFF6C2F),
                label: 'Actual intake',
              ),
              _LegendDot(
                color: Colors.black87,
                label: 'Ideal target',
              ),
              _summaryChip('Avg', '${avg.toStringAsFixed(0)} kcal'),
              _summaryChip(
                'Best day',
                '${_labelAt(labels, bestDayIndex)} (${bestValue.toStringAsFixed(0)} kcal)',
              ),
              _summaryChip(
                'High day',
                '${_labelAt(labels, worstDayIndex)} (${worstValue.toStringAsFixed(0)} kcal)',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDailyBreakdown(actual, goal, labels),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(
    List<double> actual,
    List<double> goal,
    List<String> labels,
  ) {
    final spotsPrimary = _mapToSpots(actual);
    final spotsSecondary = _mapToSpots(goal);
    final maxY = _maxY(actual, goal);
    final maxX = (spotsPrimary.length - 1).clamp(1, 30).toDouble();

    final labelCount = labels.length;
    final step = labelCount <= 6 ? 1 : (labelCount / 6).ceil();

    return LineChartData(
      gridData: FlGridData(
        drawHorizontalLine: true,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white70,
          dashArray: const [6, 6],
          strokeWidth: 1,
        ),
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (maxY / 4).clamp(100, 500),
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 44,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            final isEdge = index == 0 || index == labelCount - 1;
            if (!isEdge && (index % step) != 0) {
              return const SizedBox.shrink();
            }
            final label = _labelAt(labels, index);
            final shift = index == 0
                ? const Offset(12, 0)
                : (index == labelCount - 1 ? const Offset(-12, 0) : Offset.zero);
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Transform.translate(
                offset: shift,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.black.withOpacity(0.1)),
          bottom: BorderSide(color: Colors.black.withOpacity(0.1)),
          right: BorderSide(color: Colors.black.withOpacity(0.05)),
          top: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.black.withOpacity(0.7),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(0)} kcal',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spotsPrimary,
          isCurved: true,
          color: const Color(0xFFFF6C2F),
          barWidth: 4,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6C2F).withOpacity(0.28),
                const Color(0xFFFF6C2F).withOpacity(0.04),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        LineChartBarData(
          spots: spotsSecondary,
          isCurved: true,
          color: Colors.black87,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  List<FlSpot> _mapToSpots(List<double> values) {
    if (values.isEmpty) {
      return List.generate(7, (index) => FlSpot(index.toDouble(), 0));
    }

    return List.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index].toDouble()),
    );
  }

  double _maxY(List<double> actual, List<double> goal) {
    final combined = [...actual, ...goal];
    if (combined.isEmpty) return 400;
    final maxVal = combined.reduce(math.max);
    return (maxVal <= 0 ? 400 : maxVal + 80).toDouble();
  }

  Widget _buildDailyBreakdown(
    List<double> actual,
    List<double> goal,
    List<String> labels,
  ) {
    if (actual.isEmpty || goal.isEmpty) {
      return const Text(
        'Not enough data yet to show daily breakdown.',
        style: TextStyle(color: Colors.black54),
      );
    }

    return Column(
      children: List.generate(
        math.min(actual.length, _dayLabels.length),
        (index) {
          final intake = actual[index];
          final target = goal.length > index ? goal[index] : goal.last;
          final difference = intake - target;
          final status = difference <= 0 ? 'under' : 'over';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    _labelAt(labels, index),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: target == 0 ? 0 : (intake / target).clamp(0, 1.5),
                    backgroundColor: Colors.white24,
                    color: difference <= 0 ? const Color(0xFF1DD06C) : const Color(0xFFFF6C2F),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${intake.toStringAsFixed(0)} kcal',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: difference <= 0 ? const Color(0xFF1DD06C) : const Color(0xFFFF6C2F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistribution(AnalysisRange data) {
    const labelStyle = TextStyle(
      color: Colors.black87,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );

    const subText = TextStyle(
      color: Colors.black87,
      fontSize: 15,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF59C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Macro Distribution', style: labelStyle),
          const SizedBox(height: 4),
          const Text("You're consistently low on protein.", style: subText),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  label: 'Fats',
                  percentage: '${data.fatsPercentage.toStringAsFixed(0)}%',
                  background: const Color(0xFFE4C7FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroCard(
                  label: 'Carbs',
                  percentage: '${data.carbsPercentage.toStringAsFixed(0)}%',
                  background: const Color(0xFF8EF1B7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MacroCard(
                  label: 'Protein',
                  percentage: '${data.proteinPercentage.toStringAsFixed(0)}%',
                  background: const Color(0xFFFFAD8B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int _minIndex(List<double> values) {
  if (values.isEmpty) return 0;
  var min = values.first;
  var index = 0;
  for (var i = 1; i < values.length; i++) {
    if (values[i] < min) {
      min = values[i];
      index = i;
    }
  }
  return index;
}

int _maxIndex(List<double> values) {
  if (values.isEmpty) return 0;
  var max = values.first;
  var index = 0;
  for (var i = 1; i < values.length; i++) {
    if (values[i] > max) {
      max = values[i];
      index = i;
    }
  }
  return index;
}

String _labelAt(List<String> labels, int index) {
  final defaults = _AnalysisView._dayLabels;
  if (labels.isEmpty) {
    return defaults[index % defaults.length];
  }
  if (index < 0) return labels.first;
  return labels[index % labels.length];
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String percentage;
  final Color background;

  const _MacroCard({
    required this.label,
    required this.percentage,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
