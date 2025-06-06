// services/medical_record_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medical_record.dart';

class MedicalRecordService {
  static final MedicalRecordService _instance = MedicalRecordService._internal();
  factory MedicalRecordService() => _instance;
  MedicalRecordService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medical_records.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, path);
    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
  }

  Future<int> insert(MedicalRecord record) async {
    final db = await database;
    return await db.insert('medical_records', record.toMap());
  }

  Future<MedicalRecord?> getById(int id) async {
    final db = await database;
    final maps = await db.query('medical_records', where: 'record_id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return MedicalRecord.fromMap(maps.first);
    return null;
  }

  Future<List<MedicalRecord>> getAll() async {
    final db = await database;
    final maps = await db.query('medical_records');
    return maps.map((e) => MedicalRecord.fromMap(e)).toList();
  }

  Future<int> update(MedicalRecord record) async {
    final db = await database;
    return await db.update(
      'medical_records',
      record.toMap(),
      where: 'record_id = ?',
      whereArgs: [record.recordId],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('medical_records', where: 'record_id = ?', whereArgs: [id]);
  }
}
