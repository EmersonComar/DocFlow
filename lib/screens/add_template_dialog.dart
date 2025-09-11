import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/template_model.dart';

class AddTemplateDialog extends StatefulWidget {
  final Template? template; // Torna o template opcional

  const AddTemplateDialog({super.key, this.template});

  @override
  _AddTemplateDialogState createState() => _AddTemplateDialogState();
}

class _AddTemplateDialogState extends State<AddTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _conteudoController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estiver editando
    _tituloController = TextEditingController(text: widget.template?.titulo ?? '');
    _conteudoController = TextEditingController(text: widget.template?.conteudo ?? '');
    _tagsController = TextEditingController(text: widget.template?.tags.join(', ') ?? '');
  }

  void _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.template != null;

      final templateData = Template(
        id: widget.template?.id, // Mantém o ID se estiver editando
        titulo: _tituloController.text,
        conteudo: _conteudoController.text,
        tags: _tagsController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList(),
      );

      if (isEditing) {
        await DatabaseHelper.instance.update(templateData);
      } else {
        await DatabaseHelper.instance.create(templateData);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Template' : 'Novo Template'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              TextFormField(
                controller: _conteudoController,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o conteúdo';
                  }
                  return null;
                },
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveTemplate,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
