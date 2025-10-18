import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_notifier.dart';
import '../providers/locale_provider.dart';
import '../providers/template_provider.dart';
import '../../generated/app_localizations.dart';
import '../../data/datasources/local_database.dart';

/// SettingsScreen consolidates all application settings in one place:
/// - Theme selection
/// - Language selection
/// - Project switching
/// 
/// This screen follows Material Design 3 guidelines and uses
/// standard ListTile widgets for consistent look and feel.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Theme Section
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: context.watch<ThemeNotifier>().themeMode,
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  context.read<ThemeNotifier>().setThemeMode(mode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkTheme),
                ),
              ],
            ),
          ),
          const Divider(),

          // Language Section
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.language),
            trailing: DropdownButton<String?>(
              value: context.watch<LocaleProvider>().locale?.languageCode,
              onChanged: (String? languageCode) {
                final provider = context.read<LocaleProvider>();
                if (languageCode == null) {
                  provider.clearLocale();
                } else {
                  provider.setLocale(Locale(languageCode));
                }
              },
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.systemLanguage),
                ),
                const DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                const DropdownMenuItem(
                  value: 'es',
                  child: Text('Español'),
                ),
                const DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Project Section
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(l10n.openProject),
            onTap: () async {
              final db = context.read<LocalDatabase>();
              final themeNotifierInstance = context.read<ThemeNotifier>();
              final localeProviderInstance = context.read<LocaleProvider>();
              final templateProviderInstance = context.read<TemplateProvider>();
              final messenger = ScaffoldMessenger.of(context);

              const XTypeGroup dbGroup = XTypeGroup(extensions: <String>['db', 'sqlite']);
              final file = await openFile(acceptedTypeGroups: <XTypeGroup>[dbGroup]);
              if (file == null) return;

              try {
                // Close existing DB if open
                try {
                  await db.close();
                } catch (_) {}

                // Initialize new DB at chosen path
                await db.initialize(dbPath: file.path);

                // Persist the choice
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('db_path', file.path);

                // Reload theme and locale from the new DB
                try {
                  await themeNotifierInstance.loadTheme();
                } catch (_) {}

                try {
                  await localeProviderInstance.reload();
                } catch (_) {}

                // Force TemplateProvider to reinitialize and refresh templates
                try {
                  await templateProviderInstance.initialize();
                  await templateProviderInstance.refreshTemplates();
                } catch (_) {}

                if (!mounted) return;
                
                messenger.showSnackBar(const SnackBar(content: Text('Projeto alterado com sucesso')));
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text('Falha ao abrir banco: $e')));
              }
            },
          ),
        ],
      ),
    );
  }
}