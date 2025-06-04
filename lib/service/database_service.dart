// services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'nutrition_app.db';
  static const int _databaseVersion = 2; // Incrementé la versión para migración

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
      onUpgrade: _onUpgrade, // Agregué migración
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
        // La columna ya existe o hay otro error
        print('Error agregando chronic_disease: $e');
      }

      // Verificar que has_medical_condition exista
      try {
        await db.execute('ALTER TABLE users ADD COLUMN has_medical_condition INTEGER DEFAULT 0');
      } catch (e) {
        // La columna ya existe
        print('has_medical_condition ya existe: $e');
      }
    }
  }

  Future<void> _insertTestData(Database db) async {
    // Usuario paciente de prueba
    await db.insert('users', {
      'email': 'paciente@test.com',
      'password': 'password123', // En producción usar hash
      'role': 'patient',
      'first_name': 'Juan',
      'last_name': 'Pérez',
      'birth_date': '1990-05-15',
      'phone': '+51987654321',
      'height': 175.0,
      'weight': 70.5,
      'has_medical_condition': 0,
      'chronic_disease': 'Diabetes',
      'allergies': 'Lacteos',
      'dietary_preferences': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Usuario nutricionista de prueba
    await db.insert('users', {
      'email': 'nutricionista@test.com',
      'password': 'password123',
      'role': 'nutritionist',
      'first_name': 'Dra. Ana',
      'last_name': 'García',
      'has_medical_condition': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
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