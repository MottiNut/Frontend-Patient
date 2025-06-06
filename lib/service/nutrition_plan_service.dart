// services/nutrition_plan_service.dart
import 'package:frontendpatient/models/patient_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/nutrition_plan.dart';

class NutritionPlanService {
  static final NutritionPlanService _instance = NutritionPlanService._internal();
  factory NutritionPlanService() => _instance;
  NutritionPlanService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutrition_plans.db');
    return _database!;
  }

  Future<List<NutritionPlan>> getByPatientId(int patientId, Patient patient) async {
    try {
      final db = await database;

      // ✅ Debug: Verificar qué datos tenemos
      print('Buscando planes para paciente ID: $patientId');

      final maps = await db.query(
        'nutrition_plans',
        where: 'patients_users_user_id = ?',
        whereArgs: [patientId],
      );

      print('Planes encontrados: ${maps.length}');
      print('Datos encontrados: $maps');

      return maps.map((map) => NutritionPlan.fromMap(map, patient)).toList();
    } catch (e) {
      print('Error al obtener planes de nutrición: $e');
      return [];
    }
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, path);

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE nutrition_plans (
            plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
            nutritionists_users_id INTEGER,
            patients_users_user_id INTEGER,
            medical_records_rec INTEGER,
            energy_requirement INTEGER,
            creation_date TEXT,
            status TEXT
          )
        ''');

        // ✅ Insertar datos de prueba automáticamente
        await _insertTestData(db);
      },
    );
  }

  // ✅ Método para insertar datos de prueba
  Future<void> _insertTestData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insertar plan de prueba para paciente con ID 1
    await db.insert('nutrition_plans', {
      'nutritionists_users_id': 1,
      'patients_users_user_id': 1, // ✅ Asegúrate de que coincida con tu paciente
      'medical_records_rec': 1,
      'energy_requirement': 2000,
      'creation_date': now,
      'status': 'validated',
    });

    print('Plan de prueba insertado para paciente ID: 1');
  }

  Future<int> insert(NutritionPlan plan) async {
    final db = await database;
    return await db.insert('nutrition_plans', plan.toMap());
  }

  Future<int> getAllNutritionPlans() async {
    final db = await database;
    final maps = await db.query('nutrition_plans');
    return maps.length;
  }

  Future<int> update(NutritionPlan plan) async {
    final db = await database;
    return await db.update(
      'nutrition_plans',
      plan.toMap(),
      where: 'plan_id = ?',
      whereArgs: [plan.planId],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('nutrition_plans', where: 'plan_id = ?', whereArgs: [id]);
  }
}