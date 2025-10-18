import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/template_model.dart';

abstract class Migration {
  int get version;
  Future<void> up(Database db);
  Future<void> down(Database db);
}

class MigrationV1 implements Migration {
  @override
  int get version => 1;

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        conteudo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS template_tags (
        template_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (template_id, tag_id),
        FOREIGN KEY (template_id) REFERENCES templates (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS template_tags');
    await db.execute('DROP TABLE IF EXISTS tags');
    await db.execute('DROP TABLE IF EXISTS templates');
    await db.execute('DROP TABLE IF EXISTS user_preferences');
  }
}

class MigrationV2 implements Migration {
  @override
  int get version => 2;

  @override
  Future<void> up(Database db) async {
    await db.execute('CREATE INDEX IF NOT EXISTS idx_template_tags_template ON template_tags(template_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_template_tags_tag ON template_tags(tag_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name)');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_template_tags_template');
    await db.execute('DROP INDEX IF EXISTS idx_template_tags_tag');
    await db.execute('DROP INDEX IF EXISTS idx_tags_name');
  }
}

class LocalDatabase {
  Database? _database;
  
  static const int _currentVersion = 2;
  
  final List<Migration> _migrations = [
    MigrationV1(),
    MigrationV2(),
  ];

  /// Initialize the database. If [dbPath] is provided the database will be
  /// opened/created at that path. Otherwise it falls back to the default
  /// application documents directory (legacy behavior).
  /// If [forceNew] is true, any existing database at [dbPath] will be deleted.
  Future<void> initialize({String? dbPath, bool forceNew = false}) async {
    if (_database != null) return;

    final path = dbPath ??
        join((await getApplicationDocumentsDirectory()).path, 'templates.db');

    if (forceNew && dbPath != null) {
      // Deleta o banco existente, se houver
      try {
        await deleteDatabase(path);
      } catch (_) {
        // Ignora erros se o arquivo não existir
      }
    }

    _database = await openDatabase(
      path,
      version: _currentVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 10000');
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final migration in _migrations) {
      await migration.up(db);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (final migration in _migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        await migration.up(db);
      }
    }
  }

  Database get db {
    if (_database == null) throw StateError('Database not initialized');
    return _database!;
  }

  Future<int> insertTemplate(TemplateModel template) async {
    return await db.insert('templates', template.toMap());
  }

  Future<int> updateTemplate(TemplateModel template) async {
    return await db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> deleteTemplate(int id) async {
    return await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTemplateTags(int templateId, List<String> tags) async {
    await db.delete('template_tags', where: 'template_id = ?', whereArgs: [templateId]);

    for (final tagName in tags) {
      final trimmed = tagName.trim();
      if (trimmed.isEmpty) continue;

      int tagId;
      final existing = await db.query('tags', where: 'name = ?', whereArgs: [trimmed]);
      
      if (existing.isNotEmpty) {
        tagId = existing.first['id'] as int;
      } else {
        tagId = await db.insert('tags', {'name': trimmed});
      }

      await db.insert('template_tags', {
        'template_id': templateId,
        'tag_id': tagId,
      });
    }

    await _cleanupOrphanedTags();
  }

  Future<void> _cleanupOrphanedTags() async {
    await db.rawDelete('''
      DELETE FROM tags
      WHERE NOT EXISTS (
        SELECT 1 
        FROM template_tags tt 
        WHERE tt.tag_id = tags.id
      )
    ''');
  }

  Future<void> cleanupOrphanedTags() async {
    await _cleanupOrphanedTags();
  }

  Future<List<TemplateModel>> queryTemplates({
    int limit = 10,
    int offset = 0,
    List<String> tags = const [],
    String searchQuery = '',
  }) async {
    final buffer = StringBuffer('''
      SELECT t.id, t.titulo, t.conteudo, GROUP_CONCAT(tags.name) as tags
      FROM templates t
      LEFT JOIN template_tags tt ON t.id = tt.template_id
      LEFT JOIN tags ON tt.tag_id = tags.id
    ''');

    final params = <dynamic>[];
    final whereClauses = <String>[];

    if (tags.isNotEmpty) {
      whereClauses.add('''
        t.id IN (
          SELECT tt.template_id
          FROM template_tags tt
          JOIN tags tg ON tt.tag_id = tg.id
          WHERE tg.name IN (${tags.map((_) => '?').join(',')})
          GROUP BY tt.template_id
          HAVING COUNT(DISTINCT tg.id) = ?
        )
      ''');
      params.addAll(tags);
      params.add(tags.length);
    }

    if (searchQuery.isNotEmpty) {
      whereClauses.add('(t.titulo LIKE ? OR t.conteudo LIKE ?)');
      params.add('%$searchQuery%');
      params.add('%$searchQuery%');
    }

    if (whereClauses.isNotEmpty) {
      buffer.write(' WHERE ${whereClauses.join(' OR ')}');
    }

    buffer.write(' GROUP BY t.id ORDER BY t.id DESC LIMIT ? OFFSET ?');
    params.add(limit);
    params.add(offset);

    final result = await db.rawQuery(buffer.toString(), params);
    return result.map((map) => TemplateModel.fromMap(map)).toList();
  }

  Future<List<String>> queryAllTags() async {
    final result = await db.query('tags', columns: ['name'], orderBy: 'name ASC');
    return result.map((map) => map['name'] as String).toList();
  }

  Future<void> savePreference(String key, String value) async {
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String key) async {
    final result = await db.query('user_preferences', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}