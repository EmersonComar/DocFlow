import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/local_database.dart';
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
        await _createInitialTemplate();
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

  Future<void> _createInitialTemplate() async {
    final initialTemplate = TemplateModel(
      titulo: 'Tutorial: Como Usar o DocFlow',
      conteudo: '''Bem-vindo ao DocFlow! Este tutorial rápido irá guiá-lo pelas funcionalidades principais:

1.  **Adicionar Novo Template:** Clique no botão de '+' no canto inferior direito para criar uma nova anotação ou template. Preencha o título, conteúdo e adicione tags para facilitar a organização.

2.  **Buscar Templates:** Use a barra de pesquisa no painel esquerdo para encontrar templates por título ou conteúdo.

3.  **Filtrar por Tags:** No painel esquerdo, você pode selecionar tags para filtrar os templates e ver apenas aqueles que correspondem às tags escolhidas.

4.  **Editar Template:** Clique no ícone de três pontos ao lado de um template e selecione "Editar".

5.  **Deletar Template:** Clique no ícone de três pontos ao lado de um template e selecione "Deletar".

6.  **Copiar Conteúdo:** Use o botão 'Copiar' dentro de cada template para copiar rapidamente seu conteúdo para a área de transferência.

7.  **Alterar Tema (Claro/Escuro):** No canto superior direito da barra de aplicativos, clique no ícone de sol/lua para alternar entre o tema claro e escuro.

Esperamos que você aproveite o DocFlow!''',
      tags: ['tutorial'],
    );

    final id = await _database.insertTemplate(initialTemplate);
    await _database.updateTemplateTags(id, initialTemplate.tags);
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