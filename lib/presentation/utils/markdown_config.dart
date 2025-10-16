import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../widgets/code_block_with_copy.dart';

class MarkdownConfig {
  static MarkdownStyleSheet getStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      codeblockPadding: EdgeInsets.zero,
      codeblockDecoration: const BoxDecoration(),
    );
  }

  static MarkdownElementBuilder getCodeBlockBuilder() {
    return CodeBlockElementBuilder();
  }
}

class CodeBlockElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'code') return null;

    final code = element.textContent;
    String? language;
    
    if (element.attributes['class'] != null) {
      // Remove 'language-' prefix if present
      language = element.attributes['class']!.replaceFirst('language-', '');
    }

    // Normalize language identifier
    language = _normalizeLanguage(language);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CodeBlockWithCopy(
        code: code,
        language: language,
      ),
    );
  }

  String? _normalizeLanguage(String? language) {
    if (language == null) return null;
    
    // Map common language aliases to their standard names
    return switch (language.toLowerCase()) {
      'js' => 'javascript',
      'ts' => 'typescript',
      'py' => 'python',
      'rb' => 'ruby',
      'shell' => 'bash',
      'yml' => 'yaml',
      _ => language.toLowerCase(),
    };
  }
}