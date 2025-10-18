import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'DocFlow'**
  String get appTitle;

  /// No description provided for @filters.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @tags.
  ///
  /// In pt, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @noTagsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tag encontrada.'**
  String get noTagsFound;

  /// No description provided for @copyCodeSnack.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado!'**
  String get copyCodeSnack;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Copiar código'**
  String get copyCodeTooltip;

  /// No description provided for @editTemplate.
  ///
  /// In pt, this message translates to:
  /// **'Editar Template'**
  String get editTemplate;

  /// No description provided for @newTemplate.
  ///
  /// In pt, this message translates to:
  /// **'Novo Template'**
  String get newTemplate;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @titleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get titleLabel;

  /// No description provided for @contentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo'**
  String get contentLabel;

  /// No description provided for @pleaseInsertTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira um título'**
  String get pleaseInsertTitle;

  /// No description provided for @pleaseInsertContent.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, insira o conteúdo'**
  String get pleaseInsertContent;

  /// No description provided for @tagsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tags (separadas por vírgula)'**
  String get tagsLabel;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar Novamente'**
  String get tryAgain;

  /// No description provided for @noTemplatesFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum template encontrado.'**
  String get noTemplatesFound;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Exclusão'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteContent.
  ///
  /// In pt, this message translates to:
  /// **'Você tem certeza que deseja deletar o template \"{title}\"?'**
  String confirmDeleteContent(Object title);

  /// No description provided for @cancelButton.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Deletar'**
  String get delete;

  /// No description provided for @contentCopied.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo copiado!'**
  String get contentCopied;

  /// No description provided for @copy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @changeTheme.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Tema'**
  String get changeTheme;

  /// No description provided for @newTemplateFab.
  ///
  /// In pt, this message translates to:
  /// **'Novo Template'**
  String get newTemplateFab;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
