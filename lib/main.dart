import 'dart:io';
import 'package:docflow/providers/template_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';
import 'theme/theme_notifier.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln('Uso: docflow [opções]');
    stdout.writeln('Opções:');
    stdout.writeln('  -v, --version    Mostra a versão do aplicativo');
    stdout.writeln('  -h, --help       Mostra esta mensagem de ajuda');
    exit(0);
  }

  if (args.contains('--version') || args.contains('-v')) {
    final pubspecFile = File('pubspec.yaml').readAsStringSync();
    final pubspec = loadYaml(pubspecFile);
    stdout.writeln('DocFlow versão ${pubspec['version']}');
    exit(0);
  }

  runGui();
}

void runGui() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeNotifier),
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
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