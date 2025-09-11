import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/template_model.dart';

class AddTemplateDialog extends StatefulWidget {
  const AddTemplateDialog({super.key});

  @override
  _AddTemplateDialogState createState() => _AddTemplateDialogState();
}

class _AddTemplateDialogState extends State<AddTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  final _tagsController = TextEditingController();

  void _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      final newTemplate = Template(
        titulo: _tituloController.text,
        conteudo: _conteudoController.text,
        tags: _tagsController.text.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList(),
      );

      await DatabaseHelper.instance.create(newTemplate);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Template'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
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
                decoration: const InputDecoration(labelText: 'Conteúdo'),
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
                decoration: const InputDecoration(labelText: 'Tags (separadas por vírgula)'),
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
