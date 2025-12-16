import 'package:equatable/equatable.dart';

class CustomFood extends Equatable {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final bool isFavorite;

  const CustomFood({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isFavorite = false,
  });

  static const empty = CustomFood(
    id: '',
    name: '',
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    isFavorite: false,
  );

  CustomFood copyWith({
    String? id,
    String? name,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    bool? isFavorite,
  }) {
    return CustomFood(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, name, calories, protein, carbs, fat, isFavorite];
}
