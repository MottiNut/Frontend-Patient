// services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'nutrition_app.db';
  static const int _databaseVersion = 3; // Incrementé la versión para forzar recreación

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de usuarios/pacientes con TODAS las columnas necesarias
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'patient',
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      birth_date TEXT,
      phone TEXT,
      height REAL,
      weight REAL,
      has_medical_condition INTEGER DEFAULT 0,
      chronic_disease TEXT,
      allergies TEXT,
      dietary_preferences TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT
    )
  ''');

    // Tabla medical_records
    await db.execute('''
    CREATE TABLE medical_records (
      record_id INTEGER PRIMARY KEY AUTOINCREMENT,
      patients_users_user_id INTEGER,
      nutritionists_users_user_id INTEGER,
      appointments_appointments_id INTEGER,
      healthcare_facility TEXT,
      service_date TEXT,
      residence_location TEXT,
      family_nucleus TEXT,
      occupation TEXT,
      education_level TEXT,
      marital_status TEXT,
      religion TEXT,
      id_number TEXT,
      previous_diagnosis TEXT,
      illness_duration TEXT,
      recent_diagnosis TEXT,
      family_history TEXT,
      creation_date TEXT
    )
  ''');

    // Tabla meals
    await db.execute('''
    CREATE TABLE meals (
      meal_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      calories INTEGER,
      prep_time_minutes INTEGER,
      creation_date TEXT
    )
  ''');

    // Tabla nutrition_plans
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

    // Tabla plan_details
    await db.execute('''
    CREATE TABLE plan_details (
      plan_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
      nutrition_plan_id INTEGER,
      meal_type TEXT,
      description TEXT,
      creation_date TEXT,
      meals_meal_id INTEGER
    )
  ''');

    // Insertar algunos datos de prueba
    await _insertTestData(db);
  }

  // Migración para agregar columnas faltantes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columna chronic_disease si no existe
      try {
        await db.execute('ALTER TABLE users ADD COLUMN chronic_disease TEXT');
      } catch (e) {
        print('Error agregando chronic_disease: $e');
      }

      // Verificar que has_medical_condition exista
      try {
        await db.execute('ALTER TABLE users ADD COLUMN has_medical_condition INTEGER DEFAULT 0');
      } catch (e) {
        print('has_medical_condition ya existe: $e');
      }
    }

    if (oldVersion < 3) {
      // Recrear datos de prueba para corregir el problema del paciente 1
      await _insertTestData(db);
    }
  }

  Future<void> _insertTestData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Limpiar datos existentes primero
    await db.delete('plan_details');
    await db.delete('nutrition_plans');
    await db.delete('meals');
    await db.delete('medical_records');
    await db.delete('users');

    // ================================
    // Paciente 1: Juan Pérez
    // ================================
    final patient1Id = await db.insert('users', {
      'email': 'juan.perez@test.com',
      'password': '123456',
      'role': 'patient',
      'first_name': 'Juan',
      'last_name': 'Pérez',
      'birth_date': '1990-05-15',
      'phone': '+51911111111',
      'height': 175.0,
      'weight': 70.5,
      'has_medical_condition': 1,
      'chronic_disease': 'Diabetes',
      'allergies': 'Lactosa',
      'dietary_preferences': 'Vegetariano',
      'created_at': now,
      'updated_at': now,
    });

    print('Paciente 1 insertado con ID: $patient1Id'); // Debug

    // ================================
    // Paciente 2: María Torres
    // ================================
    final patient2Id = await db.insert('users', {
      'email': 'maria.torres@test.com',
      'password': '123456',
      'role': 'patient',
      'first_name': 'María',
      'last_name': 'Torres',
      'birth_date': '1988-08-20',
      'phone': '+51922222222',
      'height': 162.0,
      'weight': 60.0,
      'has_medical_condition': 0,
      'chronic_disease': null,
      'allergies': 'Gluten',
      'dietary_preferences': 'Sin gluten',
      'created_at': now,
      'updated_at': now,
    });

    print('Paciente 2 insertado con ID: $patient2Id'); // Debug

    // ================================
    // Nutricionista común
    // ================================
    final nutritionistId = await db.insert('users', {
      'email': 'ana.nutri@test.com',
      'password': '123456',
      'role': 'nutritionist',
      'first_name': 'Ana',
      'last_name': 'García',
      'birth_date': '1985-03-22',
      'phone': '+51933333333',
      'height': null,
      'weight': null,
      'has_medical_condition': 0,
      'chronic_disease': null,
      'allergies': null,
      'dietary_preferences': null,
      'created_at': now,
      'updated_at': now,
    });

    // ================================
    // Ficha médica paciente 1
    // ================================
    final record1Id = await db.insert('medical_records', {
      'patients_users_user_id': patient1Id,
      'nutritionists_users_user_id': nutritionistId,
      'appointments_appointments_id': 1,
      'healthcare_facility': 'Clínica Lima Salud',
      'service_date': '2024-04-01',
      'residence_location': 'Lima',
      'family_nucleus': 'Padres',
      'occupation': 'Ingeniero',
      'education_level': 'Universitario',
      'marital_status': 'Soltero',
      'religion': 'Católica',
      'id_number': '12345678',
      'previous_diagnosis': 'Hipertensión',
      'illness_duration': '5 to 10 years',
      'recent_diagnosis': 'Diabetes tipo 2',
      'family_history': 'Padre diabético',
      'creation_date': now,
    });

    // ================================
    // Ficha médica paciente 2
    // ================================
    final record2Id = await db.insert('medical_records', {
      'patients_users_user_id': patient2Id,
      'nutritionists_users_user_id': nutritionistId,
      'appointments_appointments_id': 2,
      'healthcare_facility': 'Centro Médico Sur',
      'service_date': '2024-05-10',
      'residence_location': 'Arequipa',
      'family_nucleus': 'Pareja e hijos',
      'occupation': 'Diseñadora',
      'education_level': 'Técnico',
      'marital_status': 'Casada',
      'religion': 'Agnóstica',
      'id_number': '87654321',
      'previous_diagnosis': 'Gastritis',
      'illness_duration': '< 5 years',
      'recent_diagnosis': 'Intolerancia al gluten',
      'family_history': 'Madre con colon irritable',
      'creation_date': now,
    });

    // ================================
    // Comida para paciente 1
    // ================================
    final meal1Id = await db.insert('meals', {
      'name': 'Pechuga de pollo con vegetales',
      'description': 'Pechuga a la plancha con brócoli y zanahoria',
      'calories': 450,
      'prep_time_minutes': 25,
      'creation_date': now,
    });

    // ================================
    // Comida para paciente 2
    // ================================
    final meal2Id = await db.insert('meals', {
      'name': 'Tortilla de espinaca sin gluten',
      'description': 'Huevos, espinaca, aceite de oliva',
      'calories': 350,
      'prep_time_minutes': 10,
      'creation_date': now,
    });

    // ================================
    // Plan nutricional paciente 1 - CORREGIDO
    // ================================
    final plan1Id = await db.insert('nutrition_plans', {
      'nutritionists_users_id': nutritionistId,
      'patients_users_user_id': patient1Id, // ✅ CORREGIDO: ahora usa patient1Id
      'medical_records_rec': record1Id,
      'energy_requirement': 2000,
      'creation_date': now,
      'status': 'validated',
    });

    print('Plan 1 insertado con ID: $plan1Id para paciente: $patient1Id'); // Debug

    // ================================
    // Plan nutricional paciente 2
    // ================================
    final plan2Id = await db.insert('nutrition_plans', {
      'nutritionists_users_id': nutritionistId,
      'patients_users_user_id': patient2Id,
      'medical_records_rec': record2Id,
      'energy_requirement': 1800,
      'creation_date': now,
      'status': 'validated',
    });

    print('Plan 2 insertado con ID: $plan2Id para paciente: $patient2Id'); // Debug

    // ================================
    // Detalle de plan paciente 1
    // ================================
    await db.insert('plan_details', {
      'nutrition_plan_id': plan1Id,
      'meal_type': 'lunch',
      'description': 'Almuerzo con proteína magra',
      'creation_date': now,
      'meals_meal_id': meal1Id,
    });

    // ================================
    // Detalle de plan paciente 2
    // ================================
    await db.insert('plan_details', {
      'nutrition_plan_id': plan2Id,
      'meal_type': 'breakfast',
      'description': 'Desayuno libre de gluten',
      'creation_date': now,
      'meals_meal_id': meal2Id,
    });

    // Debug: Verificar que los datos se insertaron correctamente
    final plans = await db.query('nutrition_plans');
    print('Planes insertados: $plans');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;

    // Asegurar que todos los campos requeridos estén presentes
    final userData = {
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'role': 'patient',
      'has_medical_condition': 0,
      ...user, // Los datos del usuario sobrescriben los defaults
    };

    return await db.insert('users', userData);
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;

    // Agregar updated_at automáticamente
    final userData = {
      ...user,
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  // Método para obtener usuario por ID (útil para el AuthService)
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Método para debugging - ver todos los planes
  Future<List<Map<String, dynamic>>> getAllNutritionPlans() async {
    final db = await database;
    return await db.query('nutrition_plans');
  }

  // Método para debugging - ver planes por paciente
  Future<List<Map<String, dynamic>>> getNutritionPlansByPatient(int patientId) async {
    final db = await database;
    final plans = await db.query(
      'nutrition_plans',
      where: 'patients_users_user_id = ?',
      whereArgs: [patientId],
    );
    print('Planes encontrados para paciente $patientId: $plans');
    return plans;
  }

  // Método para limpiar base de datos (solo desarrollo)
  Future<void> deleteDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    String path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    print('Base de datos eliminada');
  }

  // Método para verificar estructura de tabla (debugging)
  Future<void> printTableInfo() async {
    final db = await database;
    final result = await db.rawQuery("PRAGMA table_info(users)");
    print('Estructura de tabla users:');
    for (var column in result) {
      print('${column['name']}: ${column['type']}');
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}