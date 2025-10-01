import 'package:docflow/providers/template_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../theme/theme_notifier.dart';
import 'add_template_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddTemplateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTemplateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

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
      body: const Row(
        children: [
          SizedBox(
            width: 250,
            child: _FilterPanel(),
          ),
          Expanded(child: _TemplateList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateDialog(context),
        tooltip: 'Novo Template',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<TemplateProvider>(context, listen: false);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha((255 * 0.3).round()),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: provider.search,
            ),
            const SizedBox(height: 24),
            Text('Tags', style: textTheme.titleMedium),
            const Divider(),
            Expanded(
              child: Consumer<TemplateProvider>(
                builder: (context, provider, child) {
                  if (provider.allTags.isEmpty) {
                    return const Center(child: Text('Nenhuma tag encontrada.'));
                  }
                  return ListView.builder(
                    itemCount: provider.allTags.length,
                    itemBuilder: (context, index) {
                      final tag = provider.allTags[index];
                      return CheckboxListTile(
                        title: Text(tag),
                        value: provider.selectedTags[tag] ?? false,
                        onChanged: (bool? value) {
                          provider.updateTag(tag, value ?? false);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateList extends StatefulWidget {
  const _TemplateList();

  @override
  State<_TemplateList> createState() => _TemplateListState();
}

class _TemplateListState extends State<_TemplateList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<TemplateProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
              ),
            ),
          );
        }

        if (provider.templates.isEmpty) {
          return const Center(child: Text('Nenhum template encontrado.'));
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          itemCount: provider.templates.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.templates.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final template = provider.templates[index];
            return _TemplateCard(template: template);
          },
        );
      },
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final Template template;

  const _TemplateCard({required this.template});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isExpanded = false;

  void _showEditTemplateDialog(BuildContext context, Template template) {
    showDialog(
      context: context,
      builder: (context) => AddTemplateDialog(template: template),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Template template) {
    final provider = Provider.of<TemplateProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Você tem certeza que deseja deletar o template "${template.titulo}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: Text('Deletar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                provider.deleteTemplate(template.id!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final t = widget.template;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withAlpha((255 * 0.2).round())),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: colorScheme.onSurface.withAlpha((255 * 0.1).round()),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  _TemplateMenuButton(
                    template: t,
                    onEdit: () => _showEditTemplateDialog(context, t),
                    onDelete: () => _showDeleteConfirmationDialog(context, t),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.conteudo,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
  }
}

class _TemplateMenuButton extends StatelessWidget {
  const _TemplateMenuButton({
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  final Template template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Editar')),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(leading: Icon(Icons.delete), title: Text('Deletar')),
        ),
      ],
    );
  }
}