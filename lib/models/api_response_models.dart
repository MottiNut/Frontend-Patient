// lib/models/api_response_models.dart
class ApiResponse<T> {
  final String message;
  final T? data;
  final bool success;
  final int? statusCode;

  ApiResponse({
    required this.message,
    this.data,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.success(String message, {T? data}) {
    return ApiResponse(
      message: message,
      data: data,
      success: true,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }
}

class CreateMealResponse {
  final String message;
  final int mealId;

  CreateMealResponse({
    required this.message,
    required this.mealId,
  });

  factory CreateMealResponse.fromJson(Map<String, dynamic> json) {
    return CreateMealResponse(
      message: json['message'],
      mealId: json['meal_id'],
    );
  }
}

class CreatePlanResponse {
  final String message;
  final int planId;
  final int detailsCount;
  final int mealsCreated;
  final List<CreatedMeal> createdMeals;

  CreatePlanResponse({
    required this.message,
    required this.planId,
    required this.detailsCount,
    required this.mealsCreated,
    required this.createdMeals,
  });

  factory CreatePlanResponse.fromJson(Map<String, dynamic> json) {
    return CreatePlanResponse(
      message: json['message'],
      planId: json['plan_id'],
      detailsCount: json['details_count'],
      mealsCreated: json['meals_created'],
      createdMeals: (json['created_meals'] as List)
          .map((item) => CreatedMeal.fromJson(item))
          .toList(),
    );
  }
}

class CreatedMeal {
  final int mealId;
  final String name;

  CreatedMeal({
    required this.mealId,
    required this.name,
  });

  factory CreatedMeal.fromJson(Map<String, dynamic> json) {
    return CreatedMeal(
      mealId: json['meal_id'],
      name: json['name'],
    );
  }
}

class BatchMealResponse {
  final String message;
  final List<CreatedMeal> createdMeals;

  BatchMealResponse({
    required this.message,
    required this.createdMeals,
  });

  factory BatchMealResponse.fromJson(Map<String, dynamic> json) {
    return BatchMealResponse(
      message: json['message'],
      createdMeals: (json['created_meals'] as List)
          .map((item) => CreatedMeal.fromJson(item))
          .toList(),
    );
  }
}

class NutritionistPlanResponse {
  final int planId;
  final int nutritionistUserId;
  final int patientUserId;
  final String weekStartDate;
  final int energyRequirement;
  final String? goal;
  final String? notes;
  final String status;
  final String createdAt;
  final PatientInfo patientInfo;
  final PlanStats stats;

  NutritionistPlanResponse({
    required this.planId,
    required this.nutritionistUserId,
    required this.patientUserId,
    required this.weekStartDate,
    required this.energyRequirement,
    this.goal,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.patientInfo,
    required this.stats,
  });

  factory NutritionistPlanResponse.fromJson(Map<String, dynamic> json) {
    return NutritionistPlanResponse(
      planId: json['plan_id'],
      nutritionistUserId: json['nutritionist_user_id'],
      patientUserId: json['patient_user_id'],
      weekStartDate: json['week_start_date'],
      energyRequirement: json['energy_requirement'],
      goal: json['goal'],
      notes: json['notes'],
      status: json['status'],
      createdAt: json['created_at'],
      patientInfo: PatientInfo.fromJson(json['patient_info']),
      stats: PlanStats.fromJson(json['stats']),
    );
  }
}

class PatientInfo {
  final String firstName;
  final String lastName;
  final String email;

  PatientInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class PlanStats {
  final int totalMeals;
  final int totalWeeklyCalories;

  PlanStats({
    required this.totalMeals,
    required this.totalWeeklyCalories,
  });

  factory PlanStats.fromJson(Map<String, dynamic> json) {
    return PlanStats(
      totalMeals: json['total_meals'],
      totalWeeklyCalories: json['total_weekly_calories'],
    );
  }
}

class HealthResponse {
  final String status;
  final String message;
  final String version;
  final String timestamp;

  HealthResponse({
    required this.status,
    required this.message,
    required this.version,
    required this.timestamp,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'],
      message: json['message'],
      version: json['version'],
      timestamp: json['timestamp'],
    );
  }
}