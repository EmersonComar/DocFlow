import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:docflow/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/local_database.dart';
import 'data/repositories/template_repository_impl.dart';
import 'presentation/providers/template_provider.dart';
import 'presentation/providers/theme_notifier.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'screens/welcome_screen.dart';

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

  // Check if a database path was previously saved. If present, initialize
  // the LocalDatabase at that path. Otherwise the app will show the
  // WelcomeScreen which can create/open a database and persist the path.
  final prefs = await SharedPreferences.getInstance();
  var savedPath = prefs.getString('db_path');
  var showMissingDbDialog = false;

  // If there's a saved path, verify the file still exists before opening it.
  if (savedPath != null && savedPath.isNotEmpty) {
    final file = File(savedPath);
    final exists = await file.exists();
    if (!exists) {
      // The saved DB file was removed. Clear preference and fall back to welcome.
      await prefs.remove('db_path');
      savedPath = null;
      showMissingDbDialog = true;
      stdout.writeln('Saved database path not found, falling back to WelcomeScreen.');
    } else {
      try {
        await database.initialize(dbPath: savedPath);
      } catch (e) {
        // If initialization fails for any reason, clear the saved path and
        // fall back to the welcome flow so the user can choose another DB.
        await prefs.remove('db_path');
        savedPath = null;
        showMissingDbDialog = true;
        stdout.writeln('Failed to open saved DB at $savedPath: $e');
      }
    }
  }

  final themeNotifier = ThemeNotifier(database);
  await themeNotifier.loadTheme();

  // Decide initial home: WelcomeScreen when no saved path, otherwise HomeScreen
  final Widget initialHome = (savedPath == null || savedPath.isEmpty)
    ? WelcomeScreen(database: database, showMissingDbDialog: showMissingDbDialog)
    : const HomeScreen();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalDatabase>.value(value: database),
        ChangeNotifierProvider.value(value: themeNotifier),
        ChangeNotifierProvider(create: (_) => LocaleProvider(database)),
        ChangeNotifierProvider(
          create: (_) => TemplateProvider(templateRepository),
        ),
      ],
      child: MyApp(home: initialHome),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget home;

  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, LocaleProvider>(
      builder: (context, themeNotifier, localeProvider, child) {
        return MaterialApp(
          title: 'DocFlow',
          // Localization setup
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            // Default to Portuguese when detection fails
            if (locale == null) return const Locale('pt');
            for (var supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) return supported;
            }
            return const Locale('pt');
          },
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
          home: home,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}