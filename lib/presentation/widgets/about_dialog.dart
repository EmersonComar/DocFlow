import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../generated/app_localizations.dart';

/// Shows the application's about dialog with version information
/// and other metadata fetched from PackageInfo.
Future<void> showAppAboutDialog(BuildContext context) async {
  // Capture values before the async gap
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  
  if (!context.mounted) return;
  
  showAboutDialog(
    context: context,
    applicationName: l10n.appTitle,
    applicationVersion: packageInfo.version,
    applicationIcon: const FlutterLogo(size: 64),
    children: [
      const SizedBox(height: 24),
      Text('© ${DateTime.now().year} Emerson Comar'),
      const SizedBox(height: 8),
      InkWell(
        onTap: () {}, // TODO: Add URL launcher to open GitHub repo
        child: Text(
          'github.com/EmersonComar/DocFlow',
          style: TextStyle(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ],
  );
}