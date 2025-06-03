// services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'nutrition_app.db';
  static const int _databaseVersion = 1;

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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de usuarios/pacientes
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        birth_date TEXT,
        phone TEXT,
        height REAL,
        weight REAL,
        medical_conditions TEXT,
        allergies TEXT,
        dietary_preferences TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Insertar algunos datos de prueba
    await _insertTestData(db);
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
      'created_at': DateTime.now().toIso8601String(),
    });

    // Usuario nutricionista de prueba (no podrá acceder)
    await db.insert('users', {
      'email': 'nutricionista@test.com',
      'password': 'password123',
      'role': 'nutritionist',
      'first_name': 'Dra. Ana',
      'last_name': 'García',
      'created_at': DateTime.now().toIso8601String(),
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
    return await db.insert('users', user);
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}