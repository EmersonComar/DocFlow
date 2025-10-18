import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local_database.dart';
import '../presentation/screens/home_screen.dart';

/// WelcomeScreen shown on first run when there's no saved database path.
///
/// Provides two actions:
/// - Create new project: select a directory and filename for the .db file.
/// - Open existing project: pick an existing .db file.
///
/// After successful creation/opening the chosen path is saved to
/// SharedPreferences under the key 'db_path' and LocalDatabase.initialize
/// is called with that path.
class WelcomeScreen extends StatefulWidget {
  final LocalDatabase database;
  final bool showMissingDbDialog;

  const WelcomeScreen({super.key, required this.database, this.showMissingDbDialog = false});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // If requested, show a dialog informing the user that the previously
    // configured database file was not found and ask whether they want to
    // choose another file now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showMissingDbDialog && mounted) {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Arquivo não encontrado'),
              content: const Text('O arquivo de banco previamente configurado não foi localizado. Deseja escolher outro arquivo agora?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                TextButton(onPressed: () {
                  Navigator.of(context).pop();
                  _openExistingProject();
                }, child: const Text('Selecionar')),
              ],
            );
          },
        );
      }
    });
  }

  Future<void> _savePathAndInit(String path) async {
    setState(() => _loading = true);
    try {
      // Ensure directory exists
      final file = File(path);
      final dir = file.parent;
      if (!await dir.exists()) await dir.create(recursive: true);

      // Initialize DB at path
      await widget.database.initialize(dbPath: path);

      // Persist chosen path in SharedPreferences for future launches
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('db_path', path);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banco carregado com sucesso')),
      );

      // Navigate to HomeScreen and remove WelcomeScreen from stack. Use a
      // MaterialPageRoute so we don't rely on named routes being defined.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      // Show error and allow user to try again
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir/criar banco: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createNewProject() async {
    // Use file_selector to pick a directory. file_selector provides a
    // cross-platform API and avoids plugin platform warnings on desktop.
    final directory = await getDirectoryPath();
    if (directory == null) return; // user canceled
    if (!mounted) return;

    // Prompt for filename using a simple dialog
    final filename = await showDialog<String?>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: 'templates.db');
        return AlertDialog(
          title: const Text('Nome do arquivo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'templates.db'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('OK')),
          ],
        );
      },
    );

  if (filename == null || filename.isEmpty) return;
  if (!mounted) return;

    final path = '$directory${Platform.pathSeparator}$filename';
    await _savePathAndInit(path);
  }

  Future<void> _openExistingProject() async {
    const XTypeGroup dbGroup = XTypeGroup(extensions: <String>['db', 'sqlite']);
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[dbGroup]);
    if (file == null) return;
    if (!mounted) return;

    await _savePathAndInit(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bem-vindo ao DocFlow')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Escolha uma opção para começar',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.create_new_folder),
                    title: const Text('Criar novo projeto'),
                    subtitle: const Text('Criar um novo arquivo .db em um diretório escolhido'),
                    onTap: _loading ? null : _createNewProject,
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text('Abrir projeto existente'),
                    subtitle: const Text('Abrir um arquivo de banco de dados existente'),
                    onTap: _loading ? null : _openExistingProject,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _openExistingProject,
              child: _loading ? const CircularProgressIndicator.adaptive() : const Text('Abrir existente'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
