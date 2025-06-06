// services/meal_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';

class MealService {
  static final MealService _instance = MealService._internal();
  factory MealService() => _instance;
  MealService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meals.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals (
        meal_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        calories INTEGER NOT NULL,
        prep_time_minutes INTEGER NOT NULL,
        creation_date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await database;
    return await db.insert('meals', meal.toMap());
  }

  Future<Meal?> getMeal(int id) async {
    final db = await database;
    final maps = await db.query(
      'meals',
      where: 'meal_id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Meal.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Meal>> getAllMeals() async {
    final db = await database;
    final result = await db.query('meals');
    return result.map((map) => Meal.fromMap(map)).toList();
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await database;
    return await db.update(
      'meals',
      meal.toMap(),
      where: 'meal_id = ?',
      whereArgs: [meal.mealId],
    );
  }

  Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete(
      'meals',
      where: 'meal_id = ?',
      whereArgs: [id],
    );
  }
}
