import 'package:docflow/providers/template_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AddTemplateDialog extends StatefulWidget {
  final Template? template;

  const AddTemplateDialog({super.key, this.template});

  @override
  AddTemplateDialogState createState() => AddTemplateDialogState();
}

class AddTemplateDialogState extends State<AddTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _conteudoController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.template?.titulo ?? '');
    _conteudoController = TextEditingController(text: widget.template?.conteudo ?? '');
    _tagsController = TextEditingController(text: widget.template?.tags.join(', ') ?? '');
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TemplateProvider>(context, listen: false);
      final isEditing = widget.template != null;

      final templateData = Template(
        id: widget.template?.id,
        titulo: _tituloController.text,
        conteudo: _conteudoController.text,
        tags: _tagsController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList(),
      );

      if (isEditing) {
        provider.updateTemplate(templateData);
      } else {
        provider.addTemplate(templateData);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Template' : 'Novo Template'),
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
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
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
                        decoration: const InputDecoration(
                          labelText: 'Conteúdo',
                          border: OutlineInputBorder(),
                          filled: true,
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (text) => setState(() {}), // Atualiza a UI no setState
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o conteúdo';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline.withAlpha((255 * 0.2).round())),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Markdown(
                          data: _conteudoController.text,
                          padding: const EdgeInsets.all(16),
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            codeblockPadding: const EdgeInsets.all(16),
                            codeblockDecoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (separadas por vírgula)',
                  border: OutlineInputBorder(),
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
          label: const Text('Cancelar'),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saveTemplate,
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}
