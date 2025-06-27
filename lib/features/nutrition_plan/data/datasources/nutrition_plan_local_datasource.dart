abstract class NutritionPlanLocalDataSource {
  Future<void> cacheDailyPlan(String key, Map<String, dynamic> plan);
  Future<Map<String, dynamic>?> getCachedDailyPlan(String key);
  Future<void> clearCache();
}

class NutritionPlanLocalDataSourceImpl implements NutritionPlanLocalDataSource {
  // Implementation using SharedPreferences or local database
  @override
  Future<void> cacheDailyPlan(String key, Map<String, dynamic> plan) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getCachedDailyPlan(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    throw UnimplementedError();
  }
}