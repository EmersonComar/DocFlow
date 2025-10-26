import '../models/template_model.dart';
import 'local_database.dart';

class InitialData {
  static const tutorialTemplate = TemplateModel(
    titulo: 'Tutorial: How to Use DocFlow',
    conteudo: '''Welcome to DocFlow! This quick tutorial will guide you through the main features:
1.  **Add New Template:** Click the “+” button in the bottom right corner to create a new annotation or template. Fill in the title, content, and add tags for easy organisation.
2.  **Search Templates:** Use the search bar on the left panel to find templates by title or content.
3.  **Filter by Tags:** In the left panel, you can select tags to filter templates and see only those that match the chosen tags.
4.  **Edit Template:** Click the three dots icon next to a template and select “Edit”.
5.  **Delete Template:** Click on the three dots icon next to a template and select ‘Delete’.
6.  **Copy Content:** Use the “Copy” button within each template to quickly copy its content to the clipboard.
7.  **Change Theme (Light/Dark):** In the top right corner of the application bar, click on the sun/moon icon to switch between light and dark themes.
8.  **Change Language:** In the top right corner, there is also a field to change the application language.

We hope you enjoy DocFlow!''',
    tags: ['tutorial'],
  );

  static const markdownGuide = TemplateModel(
      titulo: 'Markdown Guide',
      conteudo: '''# Level 1 heading
## Level 2 heading
### Level 3 heading
#### Level 4 heading
##### Level 5 heading
###### Level 6 heading

## Text emphasis
**Bold text** 
*Italic text* 
***Bold and italicised text***
~~Strikethrough text~~

## Lists
### Unordered list
- Item 1
- Item 2
  - Sub-item 2.1
  - Sub-item 2.2
- Item 3

### Ordered list
1. First item
2. Second item
3. Third item
   1. Subitem 3.1
   2. Subitem 3.2

### Task list
- [x] Task completed
- [ ] Task pending
- [ ] Other task

### Radio button
( ) unchecked
(x) checked

## Quotations
> This is a quotation.
> It can have multiple lines.
>> Nested quotation

## Code
Inline code: `var x = 10;`

Code block:
```
function example() {
  return true;
}
```

Block with syntax:
```dart
void main() {
  print(“Hello, World!”);
}
```

## Tables
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Cell 1 | Cell 2 | Cell 3 |
| Data A   | Data B   | Data C   |

## Horizontal Lines
---
***
___

## Escape Characters
Use \\ to escape special characters: \\* \\_ \\# \\[ \\]

## Paragraphs
This is a normal paragraph.

This is another paragraph separated by a blank line.

## Line Break
Line 1  
Line 2 (two spaces at the end of the previous line)''',
      tags: ['markdown'],
    );
}

Future<void> createInitialData(LocalDatabase database) async {
  final id = await database.insertTemplate(InitialData.tutorialTemplate);
  await database.updateTemplateTags(id, InitialData.tutorialTemplate.tags);

  final markdownId = await database.insertTemplate(InitialData.markdownGuide);
  await database.updateTemplateTags(markdownId, InitialData.markdownGuide.tags);
}
