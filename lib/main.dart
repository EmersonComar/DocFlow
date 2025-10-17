import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yaml/yaml.dart';

import 'data/datasources/local_database.dart';
import 'data/repositories/template_repository_impl.dart';
import 'presentation/providers/template_provider.dart';
import 'presentation/providers/theme_notifier.dart';
import 'presentation/screens/home_screen.dart';

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln('Uso: docflow [opções]');
    stdout.writeln('Opções:');
    stdout.writeln('  -v, --version    Mostra a versão do aplicativo');
    stdout.writeln('  -h, --help       Mostra esta mensagem de ajuda');
    exit(0);
  }

  if (args.contains('--version') || args.contains('-v')) {
    try {
      final pubspecFile = File('pubspec.yaml').readAsStringSync();
      final pubspec = loadYaml(pubspecFile);
      stdout.writeln('DocFlow versão ${pubspec['version']}');
    } catch (e) {
      stdout.writeln('DocFlow versão desconhecida');
    }
    exit(0);
  }

  await runGui();
}

Future<void> runGui() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final database = LocalDatabase();
  final templateRepository = TemplateRepositoryImpl(database);

  await database.initialize();

  final themeNotifier = ThemeNotifier(database);
  await themeNotifier.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeNotifier),
        ChangeNotifierProvider(
          create: (_) => TemplateProvider(templateRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'DocFlow',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF33691E),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF33691E),
          ),
          themeMode: themeNotifier.themeMode,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}