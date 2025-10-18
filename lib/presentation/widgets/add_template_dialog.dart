import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:docflow/generated/app_localizations.dart';
import '../../domain/entities/template.dart';
import '../providers/template_provider.dart';
import '../utils/markdown_config.dart';

class AddTemplateDialog extends StatefulWidget {
  final Template? template;

  const AddTemplateDialog({super.key, this.template});

  @override
  State<AddTemplateDialog> createState() => _AddTemplateDialogState();
}

class _AddTemplateDialogState extends State<AddTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _conteudoController;
  late final TextEditingController _tagsController;
  
  String _markdownPreview = '';

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.template?.titulo ?? '');
    _conteudoController = TextEditingController(text: widget.template?.conteudo ?? '');
    _tagsController = TextEditingController(text: widget.template?.tags.join(', ') ?? '');
    _markdownPreview = _conteudoController.text;
    
    _conteudoController.addListener(_updateMarkdownPreview);
  }

  @override
  void dispose() {
    _conteudoController.removeListener(_updateMarkdownPreview);
    _tituloController.dispose();
    _conteudoController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateMarkdownPreview() {
    setState(() {
      _markdownPreview = _conteudoController.text;
    });
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TemplateProvider>();
    final isEditing = widget.template != null;

    final templateData = Template(
      id: widget.template?.id,
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text,
      tags: _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );

    if (isEditing) {
      await provider.updateTemplate(templateData);
    } else {
      await provider.addTemplate(templateData);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(isEditing ? AppLocalizations.of(context)!.editTemplate : AppLocalizations.of(context)!.newTemplate),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.titleLabel,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.pleaseInsertTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _conteudoController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.contentLabel,
                          border: const OutlineInputBorder(),
                          filled: true,
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.pleaseInsertContent;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withAlpha((255 * 0.2).round()),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Markdown(
                          data: _markdownPreview,
                          padding: const EdgeInsets.all(16),
                          styleSheet: MarkdownConfig.getStyleSheet(context),
                          builders: {
                            'code': MarkdownConfig.getCodeBlockBuilder(),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tagsLabel,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.cancel),
          label: Text(AppLocalizations.of(context)!.cancel),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saveTemplate,
          icon: const Icon(Icons.save),
          label: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}