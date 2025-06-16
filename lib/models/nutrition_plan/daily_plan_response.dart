class DailyPlanResponse {
  final String date;
  final String dayName;
  final Map<String, dynamic> meals;
  final int totalCalories;
  final Map<String, num> macronutrients;

  DailyPlanResponse({
    required this.date,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
    required this.macronutrients,
  });

  factory DailyPlanResponse.fromJson(Map<String, dynamic> json) {
    return DailyPlanResponse(
      date: json['date'],
      dayName: json['dayName'],
      meals: Map<String, dynamic>.from(json['meals']),
      totalCalories: json['totalCalories'],
      macronutrients: Map<String, num>.from(json['macronutrients']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayName': dayName,
      'meals': meals,
      'totalCalories': totalCalories,
      'macronutrients': macronutrients,
    };
  }
}