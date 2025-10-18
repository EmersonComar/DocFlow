import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docflow/generated/app_localizations.dart';
import '../providers/template_provider.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.read<TemplateProvider>();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withAlpha((255 * 0.3).round()),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.filters, style: textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.search,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: provider.search,
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.tags, style: textTheme.titleMedium),
            const Divider(),
            Expanded(
              child: Consumer<TemplateProvider>(
                builder: (context, provider, child) {
                  if (provider.allTags.isEmpty) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.noTagsFound),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.allTags.length,
                    itemBuilder: (context, index) {
                      final tag = provider.allTags[index];
                      return CheckboxListTile(
                        title: Text(tag),
                        value: provider.selectedTags[tag] ?? false,
                        onChanged: (bool? value) {
                          provider.updateTag(tag, value ?? false);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}