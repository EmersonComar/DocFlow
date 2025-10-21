import '../models/template_model.dart';
import 'local_database.dart';

class InitialData {
  static const tutorialTemplate = TemplateModel(
    titulo: 'Tutorial: Como Usar o DocFlow',
    conteudo: '''Bem-vindo ao DocFlow! Este tutorial rápido irá guiá-lo pelas funcionalidades principais:
1.  **Adicionar Novo Template:** Clique no botão de '+' no canto inferior direito para criar uma nova anotação ou template. Preencha o título, conteúdo e adicione tags para facilitar a organização.
2.  **Buscar Templates:** Use a barra de pesquisa no painel esquerdo para encontrar templates por título ou conteúdo.
3.  **Filtrar por Tags:** No painel esquerdo, você pode selecionar tags para filtrar os templates e ver apenas aqueles que correspondem às tags escolhidas.
4.  **Editar Template:** Clique no ícone de três pontos ao lado de um template e selecione "Editar".
5.  **Deletar Template:** Clique no ícone de três pontos ao lado de um template e selecione "Deletar".
6.  **Copiar Conteúdo:** Use o botão 'Copiar' dentro de cada template para copiar rapidamente seu conteúdo para a área de transferência.
7.  **Alterar Tema (Claro/Escuro):** No canto superior direito da barra de aplicativos, clique no ícone de sol/lua para alternar entre o tema claro e escuro.

Esperamos que você aproveite o DocFlow!''',
    tags: ['tutorial'],
  );

  static const markdownGuide = TemplateModel(
      titulo: 'Guia Markdown',
      conteudo: '''# Título Nível 1
## Título Nível 2
### Título Nível 3
#### Título Nível 4
##### Título Nível 5
###### Título Nível 6

## Ênfase de Texto
**Texto em negrito** 
*Texto em itálico* 
***Negrito e itálico***
~~Texto riscado~~

## Listas
### Lista não ordenada
- Item 1
- Item 2
  - Subitem 2.1
  - Subitem 2.2
- Item 3

### Lista ordenada
1. Primeiro item
2. Segundo item
3. Terceiro item
   1. Subitem 3.1
   2. Subitem 3.2

### Lista de tarefas
- [x] Tarefa concluída
- [ ] Tarefa pendente
- [ ] Outra tarefa

### Radio button
( ) não marcado
(x) marcado

## Citações
> Esta é uma citação.
> Pode ter múltiplas linhas.
>> Citação aninhada

## Código
Código inline: `var x = 10;`

Bloco de código:
```
function exemplo() {
  return true;
}
```

Bloco com sintaxe:
```dart
void main() {
  print('Hello, World!');
}
```

## Tabelas
| Coluna 1 | Coluna 2 | Coluna 3 |
|----------|----------|----------|
| Célula 1 | Célula 2 | Célula 3 |
| Dado A   | Dado B   | Dado C   |

## Linhas Horizontais
---
***
___

## Caracteres de Escape
Use \\ para escapar caracteres especiais: \\* \\_ \\# \\[ \\]

## Parágrafos
Este é um parágrafo normal.

Este é outro parágrafo separado por linha em branco.

## Quebra de Linha
Linha 1  
Linha 2 (duas espaços no final da linha anterior)''',
      tags: ['markdown'],
    );
}

Future<void> createInitialData(LocalDatabase database) async {
  final id = await database.insertTemplate(InitialData.tutorialTemplate);
  await database.updateTemplateTags(id, InitialData.tutorialTemplate.tags);

  final markdownId = await database.insertTemplate(InitialData.markdownGuide);
  await database.updateTemplateTags(markdownId, InitialData.markdownGuide.tags);
}
