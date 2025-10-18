// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DocFlow';

  @override
  String get filters => 'Filtros';

  @override
  String get search => 'Buscar';

  @override
  String get tags => 'Tags';

  @override
  String get noTagsFound => 'Nenhuma tag encontrada.';

  @override
  String get copyCodeSnack => 'Código copiado!';

  @override
  String get copyCodeTooltip => 'Copiar código';

  @override
  String get editTemplate => 'Editar Template';

  @override
  String get newTemplate => 'Novo Template';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get titleLabel => 'Título';

  @override
  String get contentLabel => 'Conteúdo';

  @override
  String get pleaseInsertTitle => 'Por favor, insira um título';

  @override
  String get pleaseInsertContent => 'Por favor, insira o conteúdo';

  @override
  String get tagsLabel => 'Tags (separadas por vírgula)';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get noTemplatesFound => 'Nenhum template encontrado.';

  @override
  String get confirmDeleteTitle => 'Confirmar Exclusão';

  @override
  String confirmDeleteContent(Object title) {
    return 'Você tem certeza que deseja deletar o template \"$title\"?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get delete => 'Deletar';

  @override
  String get contentCopied => 'Conteúdo copiado!';

  @override
  String get copy => 'Copiar';

  @override
  String get settings => 'Configurações';

  @override
  String get theme => 'Tema';

  @override
  String get systemTheme => 'Tema do Sistema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get systemLanguage => 'Idioma do Sistema';

  @override
  String get openProject => 'Abrir Projeto';

  @override
  String get newProject => 'Novo Projeto';

  @override
  String get about => 'Sobre';

  @override
  String get selectProject => 'Selecionar Projeto';

  @override
  String get changeTheme => 'Alterar Tema';

  @override
  String get changeLanguage => 'Alterar Idioma';

  @override
  String get newTemplateFab => 'Adicionar novo template';
}
