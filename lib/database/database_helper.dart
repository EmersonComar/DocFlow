import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/template_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('templates.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE templates (
  id $idType,
  titulo $textType,
  conteudo $textType,
  tags $textType
)
''');
  }

  Future<Template> create(Template template) async {
    final db = await instance.database;
    final id = await db.insert('templates', template.toMap());
    return template;
  }

  Future<int> update(Template template) async {
    final db = await instance.database;
    return db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Template>> getAllTemplates() async {
    final db = await instance.database;
    final result = await db.query('templates', orderBy: 'id ASC');

    return result.map((json) => Template.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
