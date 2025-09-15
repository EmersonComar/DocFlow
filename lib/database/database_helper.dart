import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = documentsDirectory.path; 
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
  conteudo $textType
)
''');

    await db.execute('''
CREATE TABLE tags (
  id $idType,
  name $textType UNIQUE
)
''');

    await db.execute('''
CREATE TABLE template_tags (
  template_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (template_id, tag_id),
  FOREIGN KEY (template_id) REFERENCES templates (id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE user_preferences (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
)''');
  }

  Future<Template> create(Template template) async {
    final db = await instance.database;
    final templateId = await db.insert('templates', template.toMap());
    template.id = templateId;

    await _updateTemplateTags(template, db);

    return template;
  }

  Future<int> update(Template template) async {
    final db = await instance.database;
    final result = await db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );

    await _updateTemplateTags(template, db);

    return result;
  }

  Future<void> _updateTemplateTags(Template template, Database db) async {
    await db.delete('template_tags', where: 'template_id = ?', whereArgs: [template.id]);

    for (String tagName in template.tags) {
      if (tagName.trim().isEmpty) continue;

      int tagId;
      final existingTags = await db.query('tags', where: 'name = ?', whereArgs: [tagName.trim()]);
      if (existingTags.isNotEmpty) {
        tagId = existingTags.first['id'] as int;
      } else {
        tagId = await db.insert('tags', {'name': tagName.trim()});
      }

      await db.insert('template_tags', {'template_id': template.id, 'tag_id': tagId});
      await _deleteOrphanTemplateTagsAndTags(db);

    }
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    final result = await db.delete(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );

    await _deleteOrphanTemplateTagsAndTags(db);

    return result;
  }


    Future<void> _deleteOrphanTemplateTagsAndTags(Database db) async {
    await db.rawDelete('''
      DELETE FROM template_tags
      WHERE template_id IN (SELECT template_id FROM template_tags LEFT JOIN templates ON templates.id = template_tags.template_id WHERE templates.id IS NULL)
    ''');
    await db.rawDelete('''
      DELETE FROM tags WHERE id NOT IN (SELECT DISTINCT tag_id FROM template_tags)
    ''');
  }

  Future<List<Template>> getAllTemplates() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT t.id, t.titulo, t.conteudo, GROUP_CONCAT(tags.name) as tags
      FROM templates t
      LEFT JOIN template_tags tt ON t.id = tt.template_id
      LEFT JOIN tags ON tt.tag_id = tags.id
      GROUP BY t.id
      ORDER BY t.id ASC
    ''');

    return result.map((map) => Template.fromMap(map)).toList();
  }


  Future<void> savePreference(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );
  }

  Future<String?> getPreference(String key) async {
    final db = await instance.database;
    final result = await db.query('user_preferences', where: 'key = ?', whereArgs: [key]);
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
