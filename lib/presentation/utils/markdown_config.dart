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
    final language = element.attributes['class']?.split('-').last;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CodeBlockWithCopy(
        code: code,
        language: language,
      ),
    );
  }
}