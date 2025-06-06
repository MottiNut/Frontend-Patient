// services/plan_detail_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plan_detail.dart';

class PlanDetailService {
  static final PlanDetailService _instance = PlanDetailService._internal();
  factory PlanDetailService() => _instance;
  PlanDetailService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plan_details.db');
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
          CREATE TABLE plan_details (
            plan_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
            nutrition_plan_id INTEGER,
            meal_type TEXT,
            description TEXT,
            creation_date TEXT,
            meals_meal_id INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(PlanDetail detail) async {
    final db = await database;
    return await db.insert('plan_details', detail.toMap());
  }

  Future<PlanDetail?> getById(int id) async {
    final db = await database;
    final maps = await db.query('plan_details', where: 'plan_detail_id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return PlanDetail.fromMap(maps.first);
    return null;
  }

  Future<List<PlanDetail>> getAll() async {
    final db = await database;
    final maps = await db.query('plan_details');
    return maps.map((e) => PlanDetail.fromMap(e)).toList();
  }

  Future<int> update(PlanDetail detail) async {
    final db = await database;
    return await db.update(
      'plan_details',
      detail.toMap(),
      where: 'plan_detail_id = ?',
      whereArgs: [detail.planDetailId],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete('plan_details', where: 'plan_detail_id = ?', whereArgs: [id]);
  }
}
