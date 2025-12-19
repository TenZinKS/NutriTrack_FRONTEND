part of 'food_detail_cubit.dart';

class FoodDetailState {
  final CustomFood food;
  final bool isProcessing;
  final bool deleted;
  final String? message;

  const FoodDetailState({
    required this.food,
    this.isProcessing = false,
    this.deleted = false,
    this.message,
  });

  FoodDetailState copyWith({
    CustomFood? food,
    bool? isProcessing,
    bool? deleted,
    String? message,
  }) {
    return FoodDetailState(
      food: food ?? this.food,
      isProcessing: isProcessing ?? this.isProcessing,
      deleted: deleted ?? this.deleted,
      message: message,
    );
  }
}
