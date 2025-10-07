import 'package:flutter/foundation.dart';
import '../models/template_model.dart';
import '../database/database_helper.dart';

class TemplateProvider extends ChangeNotifier {
  List<Template> _templates = [];
  List<String> _allTags = [];
  final Map<String, bool> _selectedTags = {};
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _searchQuery = '';
  final int _pageSize = 10;
  int _page = 0;
  bool _hasMore = true;

  List<Template> get templates => _templates;
  List<String> get allTags => _allTags;
  Map<String, bool> get selectedTags => _selectedTags;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  TemplateProvider() {
    refreshTemplates();
  }

  Future<void> refreshTemplates() async {
    _isLoading = true;
    _errorMessage = null;
    _page = 0;
    _hasMore = true;
    _templates = [];
    notifyListeners();

    try {
      final tags = await DatabaseHelper.instance.getAllTags();
      _allTags = tags;

      final activeTags = _selectedTags.entries.where((e) => e.value).map((e) => e.key).toList();
      final data = await DatabaseHelper.instance.getTemplates(limit: _pageSize, offset: 0, tags: activeTags, searchQuery: _searchQuery);

      if (data.isEmpty && activeTags.isEmpty && _searchQuery.isEmpty) {
        final initialTemplates = [
          Template(
            titulo: 'Tutorial: Como Usar o DocFlow',
            conteudo: '''Bem-vindo ao DocFlow! Este tutorial rápido irá guiá-lo pelas funcionalidades principais:

1.  **Adicionar Novo Template:** Clique no botão de '+' no canto inferior direito para criar uma nova anotação ou template. Preencha o título, conteúdo e adicione tags para facilitar a organização.

2.  **Buscar Templates:** Use a barra de pesquisa no painel esquerdo para encontrar templates por título ou conteúdo.

3.  **Filtrar por Tags:** No painel esquerdo, você pode selecionar tags para filtrar os templates e ver apenas aqueles que correspondem às tags escolhidas.

4.  **Editar Template:** Clique no ícone de lápis ao lado de um template para editá-lo.

5.  **Deletar Template:** Clique no ícone de lixeira ao lado de um template para excluí-lo.

6.  **Copiar Conteúdo:** Use o botão 'Copiar' dentro de cada template para copiar rapidamente seu conteúdo para a área de transferência.

7.  **Alterar Tema (Claro/Escuro):** No canto superior direito da barra de aplicativos, clique no ícone de sol/lua para alternar entre o tema claro e escuro.

Esperamos que você aproveite o DocFlow!''',
            tags: ['tutorial'],
          ),
        ];

        for (var template in initialTemplates) {
          final newTemplate = await DatabaseHelper.instance.create(template);
          _templates.add(newTemplate);
        }
      } else {
        _templates.addAll(data);
      }
    } catch (e) {
      _errorMessage = 'Falha ao carregar o banco de dados.\nVerifique as permissões do diretório ou tente reiniciar a aplicação.\n\nErro: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _page++;
      final activeTags = _selectedTags.entries.where((e) => e.value).map((e) => e.key).toList();
      final data = await DatabaseHelper.instance.getTemplates(limit: _pageSize, offset: _page * _pageSize, tags: activeTags, searchQuery: _searchQuery);
      if (data.length < _pageSize) {
        _hasMore = false;
      }
      _templates.addAll(data);
    } catch (e) {
      _errorMessage = 'Falha ao carregar mais templates.\n\nErro: $e';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    refreshTemplates();
  }

  void updateTag(String tag, bool value) {
    _selectedTags[tag] = value;
    refreshTemplates();
  }

  Future<void> addTemplate(Template template) async {
    await DatabaseHelper.instance.create(template);
    await refreshTemplates();
  }

  Future<void> updateTemplate(Template template) async {
    await DatabaseHelper.instance.update(template);
    await refreshTemplates();
  }

  Future<void> deleteTemplate(int id) async {
    await DatabaseHelper.instance.delete(id);
    _templates.removeWhere((template) => template.id == id);
    if (_templates.isEmpty) {
      _selectedTags.clear();
    }
    await refreshTemplates();
  }
}