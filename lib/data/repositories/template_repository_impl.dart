import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/local_database.dart';
import '../datasources/initial_data.dart';
import '../models/template_model.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final LocalDatabase _database;
  bool _initialized = false;

  TemplateRepositoryImpl(this._database);

  @override
  Future<Result<void>> ensureInitialized() async {
    if (_initialized) return Result.success(null);

    try {
      await _database.initialize();
      
      final templates = await _database.queryTemplates(limit: 1);
      if (templates.isEmpty) {
        await createInitialData(_database);
      }
      
      _initialized = true;
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(
        'Falha ao inicializar banco de dados: ${e.toString()}',
        e,
      ));
    }
  }

  @override
  Future<Result<Template>> create(Template template) async {
    try {
      final model = TemplateModel.fromEntity(template);
      final id = await _database.insertTemplate(model);
      await _database.updateTemplateTags(id, template.tags);
      
      return Result.success(template.copyWith(id: id));
    } catch (e) {
      return Result.failure(DatabaseFailure(
        'Falha ao criar template: ${e.toString()}',
        e,
      ));
    }
  }

  @override
  Future<Result<Template>> update(Template template) async {
    if (template.id == null) {
      return Result.failure(const ValidationFailure('Template ID não pode ser nulo'));
    }

    try {
      final model = TemplateModel.fromEntity(template);
      await _database.updateTemplate(model);
      await _database.updateTemplateTags(template.id!, template.tags);
      
      return Result.success(template);
    } catch (e) {
      return Result.failure(DatabaseFailure(
        'Falha ao atualizar template: ${e.toString()}',
        e,
      ));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _database.deleteTemplate(id);
      await _database.cleanupOrphanedTags();
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(
        'Falha ao deletar template: ${e.toString()}',
        e,
      ));
    }
  }

  @override
  Future<Result<List<Template>>> getTemplates({
    int limit = 10,
    int offset = 0,
    List<String> tags = const [],
    String searchQuery = '',
  }) async {
    try {
      final models = await _database.queryTemplates(
        limit: limit,
        offset: offset,
        tags: tags,
        searchQuery: searchQuery,
      );
      
      return Result.success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure(
        'Falha ao carregar templates: ${e.toString()}',
        e,
      ));
    }
  }

  @override
  Future<Result<List<String>>> getAllTags() async {
    try {
      final tags = await _database.queryAllTags();
      return Result.success(tags);
    } catch (e) {
      return Result.failure(DatabaseFailure(
        'Falha ao carregar tags: ${e.toString()}',
        e,
      ));
    }
  }
}