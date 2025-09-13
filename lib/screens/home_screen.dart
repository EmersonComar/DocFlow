import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../database/database_helper.dart';
import '../theme/theme_notifier.dart';
import 'add_template_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Template> templates = [];
  List<Template> filteredTemplates = [];
  List<String> allTags = [];
  Map<String, bool> selectedTags = {};
  bool isLoading = true;
  String? _errorMessage;
  final Set<int> _expandedTemplates = {};

  @override
  void initState() {
    super.initState();
    _refreshTemplates();
  }

  Future<void> _refreshTemplates() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await DatabaseHelper.instance.getAllTemplates();

      if (data.isEmpty) {
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
          await DatabaseHelper.instance.create(template);
        }
        final newData = await DatabaseHelper.instance.getAllTemplates();
        _updateStateWithNewData(newData);
      } else {
        _updateStateWithNewData(data);
      }
    } catch (e) {
      _errorMessage = 'Falha ao carregar o banco de dados.\nVerifique as permissões do diretório ou tente reiniciar a aplicação.\n\nErro: $e';
    }

    setState(() {
      isLoading = false;
    });
  }

  void _updateStateWithNewData(List<Template> newData) {
    final newTags = <String>{};
    for (var template in newData) {
      if (template.tags.isNotEmpty && template.tags.first.isNotEmpty) {
        newTags.addAll(template.tags);
      }
    }

    final sortedTags = newTags.toList()..sort();
    final newSelectedTags = <String, bool>{};
    for (var tag in sortedTags) {
      newSelectedTags[tag] = selectedTags[tag] ?? false;
    }

    setState(() {
      templates = newData;
      allTags = sortedTags;
      selectedTags = newSelectedTags;
      filterTemplates();
    });
  }

  void filterTemplates() {
    String search = searchController.text.toLowerCase();
    List<String> activeTags = selectedTags.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    setState(() {
      filteredTemplates = templates.where((t) {
        bool matchesSearch =
            t.titulo.toLowerCase().contains(search) || t.conteudo.toLowerCase().contains(search);
        bool matchesTags = activeTags.isEmpty || activeTags.any((tag) => t.tags.contains(tag));
        return matchesSearch && matchesTags;
      }).toList();
    });
  }

  void _showAddTemplateDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddTemplateDialog(),
    );
    _refreshTemplates();
  }

  void _showEditTemplateDialog(Template template) async {
    await showDialog(
      context: context,
      builder: (context) => AddTemplateDialog(template: template),
    );
    _refreshTemplates();
  }

  void _showDeleteConfirmationDialog(Template template) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja deletar o template "${template.titulo}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: Text('Deletar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () async {
                await DatabaseHelper.instance.delete(template.id!);
                Navigator.of(context).pop();
                _refreshTemplates();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocFlow'),
        actions: [
          IconButton(
            icon: Icon(themeNotifier.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeNotifier.toggleTheme(),
            tooltip: 'Alterar Tema',
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      onChanged: (value) => filterTemplates(),
                    ),
                    const SizedBox(height: 24),
                    Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        children: allTags.map((tag) {
                          return CheckboxListTile(
                            title: Text(tag),
                            value: selectedTags[tag] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedTags[tag] = value ?? false;
                              });
                              filterTemplates();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) 
                : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final t = filteredTemplates[index];
                      final isExpanded = _expandedTemplates.contains(t.id);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: colorScheme.onSurface.withOpacity(0.1),
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedTemplates.remove(t.id);
                              } else {
                                _expandedTemplates.add(t.id!);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t.titulo,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditTemplateDialog(t);
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmationDialog(t);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: ListTile(leading: Icon(Icons.edit), title: Text('Editar')),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: ListTile(leading: Icon(Icons.delete), title: Text('Deletar')),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.conteudo,
                                  maxLines: isExpanded ? null : 3,
                                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 16),
                                if (t.tags.isNotEmpty && t.tags.first.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: t.tags.map((tag) => Chip(label: Text(tag))).toList(),
                                  ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: t.conteudo));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Conteúdo copiado!')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copiar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTemplateDialog,
        child: const Icon(Icons.add),
        tooltip: 'Novo Template',
      ),
    );
  }
}
