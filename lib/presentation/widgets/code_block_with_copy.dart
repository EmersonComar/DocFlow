import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlockWithCopy extends StatelessWidget {
  final String code;
  final String? language;

  const CodeBlockWithCopy({
    super.key,
    required this.code,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: SelectableText(
            code,
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: IconButton.filledTonal(
              icon: const Icon(Icons.copy, size: 18),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado!')),
                );
              },
              tooltip: 'Copiar código',
            ),
          ),
        ),
        if (language != null)
          Positioned(
            top: 8,
            left: 8,
            child: Text(
              language!,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}