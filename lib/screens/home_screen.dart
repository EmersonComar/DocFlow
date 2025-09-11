import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/template_model.dart';
import '../database/database_helper.dart';
import 'add_template_dialog.dart'; // Importa o novo diálogo

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

  @override
  void initState() {
    super.initState();
    _refreshTemplates();
  }

  Future<void> _refreshTemplates() async {
    setState(() {
      isLoading = true;
    });

    final data = await DatabaseHelper.instance.getAllTemplates();

    if (data.isEmpty) {
      // Insere dados iniciais se o banco estiver vazio
      final initialTemplates = [
        Template(
          titulo: 'Atualização do Sistema',
          conteudo: 'Desconecte os outros colaboradores antes da atualização...',
          tags: ['backup'],
        ),
        Template(
          titulo: 'Backup gerado com sucesso',
          conteudo: 'Olá, {{nome_usuario}}! Backup gerado com sucesso.',
          tags: ['backup'],
        ),
        Template(
          titulo: 'Restaurar elasticsearch',
          conteudo: 'tar -xzvf elastic_backup.tar.gz -C /var/lib/elasticsearch_backup/',
          tags: ['elasticsearch', 'restore'],
        ),
      ];

      for (var template in initialTemplates) {
        await DatabaseHelper.instance.create(template);
      }
      // Recarrega os templates após a inserção
      final newData = await DatabaseHelper.instance.getAllTemplates();
      _updateStateWithNewData(newData);
    } else {
      _updateStateWithNewData(data);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _updateStateWithNewData(List<Template> newData) {
    final newTags = <String>{};
    for (var template in newData) {
      if (template.tags.first.isNotEmpty) {
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
      filterTemplates(); // Aplica filtros com os novos dados
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
            TextButton(
              child: const Text('Deletar', style: TextStyle(color: Colors.red)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('DocFlow')),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => filterTemplates(),
                ),
                const SizedBox(height: 10),
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
          // Conteúdo
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: filteredTemplates.length,
                      itemBuilder: (context, index) {
                        Template t = filteredTemplates[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ExpansionTile(
                            title: Text(t.titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.conteudo),
                                    const SizedBox(height: 16),
                                    if (t.tags.first.isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        children: t.tags
                                            .map((tag) => Chip(label: Text(tag)))
                                            .toList(),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Deletar',
                                          onPressed: () => _showDeleteConfirmationDialog(t),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          tooltip: 'Editar',
                                          onPressed: () => _showEditTemplateDialog(t),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: t.conteudo));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text('Conteúdo copiado!')),
                                            );
                                          },
                                          icon: const Icon(Icons.copy),
                                          label: const Text('Copiar'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
