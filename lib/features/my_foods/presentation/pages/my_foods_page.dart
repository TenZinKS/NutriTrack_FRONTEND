import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/nutri_bottom_nav_bar.dart';
import '../../../analysis/presentation/pages/analysis_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../meal_planner/presentation/pages/ai_meal_planner_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/custom_food.dart';
import '../cubit/my_foods_cubit.dart';
import 'food_detail_page.dart';

class MyFoodsPage extends StatelessWidget {
  const MyFoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyFoodsCubit(
        listenCustomFoodsUsecase: sl(),
        toggleFavoriteFoodUsecase: sl(),
        deleteCustomFoodUsecase: sl(),
        updateCustomFoodUsecase: sl(),
      )..loadFoods(),
      child: const _MyFoodsView(),
    );
  }
}

class _MyFoodsView extends StatelessWidget {
  const _MyFoodsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFoodsCubit, MyFoodsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'My Foods',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTabs(context, state),
                        const SizedBox(height: 16),
                        _buildExploreCard(),
                        const SizedBox(height: 20),
                        _buildFoodsList(context, state),
                      ],
                    ),
                  ),
                ),
                NutriBottomNavBar(
                  selectedIndex: 3,
                  onAddTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiMealPlannerPage()),
                    );
                  },
                  onItemSelected: (index) {
                    if (index == 0) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                    } else if (index == 1) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AnalysisPage()),
                      );
                    } else if (index == 4) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabs(BuildContext context, MyFoodsState state) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          _tabButton(
            context,
            label: 'All Foods',
            isSelected: state.filter == MyFoodsFilter.all,
            onTap: () =>
                context.read<MyFoodsCubit>().changeFilter(MyFoodsFilter.all),
          ),
          const SizedBox(width: 6),
          _tabButton(
            context,
            label: 'My Favorites',
            isSelected: state.filter == MyFoodsFilter.favorites,
            onTap: () => context
                .read<MyFoodsCubit>()
                .changeFilter(MyFoodsFilter.favorites),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1DD06C) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFBDA9FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Foods',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Explore foods to match your goals and lifestyle.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodsList(BuildContext context, MyFoodsState state) {
    if (state.status == MyFoodsStatus.loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == MyFoodsStatus.failure) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          state.message ?? 'Unable to load foods',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final foods = state.visibleFoods;
    if (foods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text(
          'No foods saved yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...foods.map((food) => _foodTile(context, food)),
      ],
    );
  }

  Widget _foodTile(BuildContext context, CustomFood food) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FoodDetailPage(food: food),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${food.calories} kcal  |  Protein: ${food.protein}g  |  Carbs: ${food.carbs}g  |  Fat: ${food.fat}g',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

}
