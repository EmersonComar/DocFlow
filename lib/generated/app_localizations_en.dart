// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DocFlow';

  @override
  String get filters => 'Filters';

  @override
  String get search => 'Search';

  @override
  String get tags => 'Tags';

  @override
  String get noTagsFound => 'No tags found.';

  @override
  String get copyCodeSnack => 'Code copied!';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get newTemplate => 'New Template';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get titleLabel => 'Title';

  @override
  String get contentLabel => 'Content';

  @override
  String get pleaseInsertTitle => 'Please enter a title';

  @override
  String get pleaseInsertContent => 'Please enter the content';

  @override
  String get tagsLabel => 'Tags (comma separated)';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noTemplatesFound => 'No templates found.';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String confirmDeleteContent(Object title) {
    return 'Are you sure you want to delete the template \"$title\"?';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get contentCopied => 'Content copied!';

  @override
  String get copy => 'Copy';

  @override
  String get changeTheme => 'Change Theme';

  @override
  String get newTemplateFab => 'New Template';
}
