// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DocFlow';

  @override
  String get filters => 'Filtros';

  @override
  String get search => 'Buscar';

  @override
  String get tags => 'Etiquetas';

  @override
  String get noTagsFound => 'No se encontraron etiquetas.';

  @override
  String get copyCodeSnack => '¡Código copiado!';

  @override
  String get copyCodeTooltip => 'Copiar código';

  @override
  String get editTemplate => 'Editar Plantilla';

  @override
  String get newTemplate => 'Nueva Plantilla';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get titleLabel => 'Título';

  @override
  String get contentLabel => 'Contenido';

  @override
  String get pleaseInsertTitle => 'Por favor, introduce un título';

  @override
  String get pleaseInsertContent => 'Por favor, introduce el contenido';

  @override
  String get tagsLabel => 'Etiquetas (separadas por coma)';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get noTemplatesFound => 'No se encontraron plantillas.';

  @override
  String get confirmDeleteTitle => 'Confirmar Eliminación';

  @override
  String confirmDeleteContent(Object title) {
    return '¿Estás seguro que quieres eliminar la plantilla \"$title\"?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get contentCopied => '¡Contenido copiado!';

  @override
  String get copy => 'Copiar';

  @override
  String get changeTheme => 'Cambiar Tema';

  @override
  String get newTemplateFab => 'Nueva Plantilla';
}
