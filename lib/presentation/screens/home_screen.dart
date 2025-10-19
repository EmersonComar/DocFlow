import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'package:docflow/generated/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/entities/template.dart';
import '../providers/template_provider.dart';
import '../providers/theme_notifier.dart';
import '../utils/markdown_config.dart';
import '../widgets/add_template_dialog.dart';
import '../widgets/filter_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemplateProvider>().initialize();
    });
  }

  void _showAddTemplateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTemplateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: Icon(_getThemeIcon(themeNotifier.themeMode)),
            onPressed: () => themeNotifier.toggleTheme(),
            tooltip: AppLocalizations.of(context)!.changeTheme,
          ),
          PopupMenuButton<Locale?>(
            onSelected: (locale) => localeProvider.setLocale(locale),
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text('System')),
              PopupMenuItem(value:  Locale('pt'), child:  Text('Português')),
              PopupMenuItem(value:  Locale('en'), child:  Text('English')),
              PopupMenuItem(value:  Locale('es'), child:  Text('Español')),
            ],
            tooltip: 'Idioma',
          ),
        ],
      ),
      body: const Row(
        children: [
          SizedBox(width: 250, child: FilterPanel()),
          Expanded(child: _TemplateList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateDialog(context),
        tooltip: AppLocalizations.of(context)!.newTemplateFab,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.dark_mode,
      ThemeMode.dark => Icons.light_mode,
      ThemeMode.system => Icons.brightness_auto,
    };
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
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<TemplateProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.initialize(),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.templates.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noTemplatesFound),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          itemCount: provider.templates.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.templates.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _TemplateCard(template: provider.templates[index]);
          },
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final Template template;

  const _TemplateCard({required this.template});

  void _showEditTemplateDialog(BuildContext context, Template template) {
    showDialog(
      context: context,
      builder: (context) => AddTemplateDialog(template: template),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Template template) {
    showDialog(
      context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(
              AppLocalizations.of(context)!.confirmDeleteContent(template.titulo),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancelButton),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: Text(
                  AppLocalizations.of(context)!.delete,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                ),
                onPressed: () {
                  context.read<TemplateProvider>().deleteTemplate(template.id!);
                  Navigator.of(dialogContext).pop();
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
    final provider = context.watch<TemplateProvider>();
    final isExpanded = provider.isTemplateExpanded(template.id);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withAlpha((255 * 0.2).round()),
        ),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: colorScheme.onSurface.withAlpha((255 * 0.1).round()),
        onTap: () => provider.toggleTemplateExpansion(template.id),
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
                      template.titulo,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  _TemplateMenuButton(
                    template: template,
                    onEdit: () => _showEditTemplateDialog(context, template),
                    onDelete: () => _showDeleteConfirmationDialog(context, template),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              isExpanded
                  ? MarkdownBody(
                      data: template.conteudo,
                      selectable: true,
                      styleSheet: MarkdownConfig.getStyleSheet(context).copyWith(
                        p: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      builders: {
                        'code': MarkdownConfig.getCodeBlockBuilder(),
                      },
                    )
                  : Text(
                      template.conteudo,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
              const SizedBox(height: 16),
              if (template.tags.isNotEmpty && template.tags.first.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: template.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: template.conteudo));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.contentCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(AppLocalizations.of(context)!.copy),
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
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: Text(AppLocalizations.of(context)!.editTemplate),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: Text(AppLocalizations.of(context)!.delete),
          ),
        ),
      ],
    );
  }}