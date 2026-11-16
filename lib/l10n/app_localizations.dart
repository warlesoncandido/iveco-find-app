import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appHeader.
  ///
  /// In pt, this message translates to:
  /// **'Gestão de ativos'**
  String get appHeader;

  /// No description provided for @commonRequiredField.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório.'**
  String get commonRequiredField;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonRegister.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get commonRegister;

  /// No description provided for @commonEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @commonActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get commonActive;

  /// No description provided for @commonDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Desativado'**
  String get commonDisabled;

  /// No description provided for @commonName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get commonName;

  /// No description provided for @commonAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get commonAll;

  /// No description provided for @commonProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get commonProfile;

  /// No description provided for @commonStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get commonLogout;

  /// No description provided for @commonUpdatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado com sucesso!'**
  String get commonUpdatedSuccess;

  /// No description provided for @commonCreatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro realizado com sucesso!'**
  String get commonCreatedSuccess;

  /// No description provided for @commonRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get commonRetry;

  /// No description provided for @commonLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro ao carregar as informações.'**
  String get commonLoadError;

  /// No description provided for @commonLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get commonLoadMore;

  /// No description provided for @commonInvalidDate.
  ///
  /// In pt, this message translates to:
  /// **'Data inválida.'**
  String get commonInvalidDate;

  /// No description provided for @commonEmptyValue.
  ///
  /// In pt, this message translates to:
  /// **'—'**
  String get commonEmptyValue;

  /// No description provided for @drawerDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get drawerDashboard;

  /// No description provided for @drawerActives.
  ///
  /// In pt, this message translates to:
  /// **'Ativos'**
  String get drawerActives;

  /// No description provided for @drawerTypes.
  ///
  /// In pt, this message translates to:
  /// **'Tipos'**
  String get drawerTypes;

  /// No description provided for @drawerSuppliers.
  ///
  /// In pt, this message translates to:
  /// **'Fornecedores'**
  String get drawerSuppliers;

  /// No description provided for @drawerLocations.
  ///
  /// In pt, this message translates to:
  /// **'Localidades'**
  String get drawerLocations;

  /// No description provided for @drawerUsers.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get drawerUsers;

  /// No description provided for @drawerSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get drawerSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma do aplicativo.'**
  String get settingsLanguageDescription;

  /// No description provided for @languagePortugueseBrazil.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePortugueseBrazil;

  /// No description provided for @languageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @authEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Email inválido'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get authPassword;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'Senha deve ter no mínimo 6 caracteres'**
  String get authPasswordMinLength;

  /// No description provided for @authSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authSignIn;

  /// No description provided for @authLoginFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao realizar o login'**
  String get authLoginFailed;

  /// No description provided for @authLoginSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Login realizado com sucesso!'**
  String get authLoginSuccess;

  /// No description provided for @authForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get authForgotPassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trocar senha'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDescription.
  ///
  /// In pt, this message translates to:
  /// **'Você entrou com uma senha provisória. Defina uma nova senha para continuar.'**
  String get changePasswordDescription;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual (provisória)'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get changePasswordNew;

  /// No description provided for @changePasswordLength.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter de 8 a 128 caracteres'**
  String get changePasswordLength;

  /// No description provided for @changePasswordSameAsCurrent.
  ///
  /// In pt, this message translates to:
  /// **'A nova senha deve ser diferente da atual'**
  String get changePasswordSameAsCurrent;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não conferem'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nova senha'**
  String get changePasswordSave;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada com sucesso!'**
  String get changePasswordSuccess;

  /// No description provided for @activeStatusAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get activeStatusAvailable;

  /// No description provided for @activeStatusInUse.
  ///
  /// In pt, this message translates to:
  /// **'Em uso'**
  String get activeStatusInUse;

  /// No description provided for @activeStatusInMaintenance.
  ///
  /// In pt, this message translates to:
  /// **'Em manutenção'**
  String get activeStatusInMaintenance;

  /// No description provided for @activeStatusWrittenOff.
  ///
  /// In pt, this message translates to:
  /// **'Baixado'**
  String get activeStatusWrittenOff;

  /// No description provided for @movementEntry.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get movementEntry;

  /// No description provided for @movementTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Transferência'**
  String get movementTransfer;

  /// No description provided for @movementCheckout.
  ///
  /// In pt, this message translates to:
  /// **'Saída para uso'**
  String get movementCheckout;

  /// No description provided for @movementReturn.
  ///
  /// In pt, this message translates to:
  /// **'Devolução'**
  String get movementReturn;

  /// No description provided for @movementSendToMaintenance.
  ///
  /// In pt, this message translates to:
  /// **'Envio para manutenção'**
  String get movementSendToMaintenance;

  /// No description provided for @movementReturnFromMaintenance.
  ///
  /// In pt, this message translates to:
  /// **'Retorno de manutenção'**
  String get movementReturnFromMaintenance;

  /// No description provided for @movementWriteOff.
  ///
  /// In pt, this message translates to:
  /// **'Baixa'**
  String get movementWriteOff;

  /// No description provided for @profileAdministrator.
  ///
  /// In pt, this message translates to:
  /// **'Administrador'**
  String get profileAdministrator;

  /// No description provided for @profileManager.
  ///
  /// In pt, this message translates to:
  /// **'Gestor'**
  String get profileManager;

  /// No description provided for @profileOperational.
  ///
  /// In pt, this message translates to:
  /// **'Operacional'**
  String get profileOperational;

  /// No description provided for @profileViewer.
  ///
  /// In pt, this message translates to:
  /// **'Consulta'**
  String get profileViewer;

  /// No description provided for @fieldName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get fieldName;

  /// No description provided for @fieldInternalCode.
  ///
  /// In pt, this message translates to:
  /// **'Código interno'**
  String get fieldInternalCode;

  /// No description provided for @fieldSapCode.
  ///
  /// In pt, this message translates to:
  /// **'Código SAP'**
  String get fieldSapCode;

  /// No description provided for @fieldSerialNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número de série'**
  String get fieldSerialNumber;

  /// No description provided for @fieldPatrimony.
  ///
  /// In pt, this message translates to:
  /// **'Patrimônio'**
  String get fieldPatrimony;

  /// No description provided for @fieldType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get fieldType;

  /// No description provided for @fieldCategory.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get fieldCategory;

  /// No description provided for @fieldSubcategory.
  ///
  /// In pt, this message translates to:
  /// **'Subcategoria'**
  String get fieldSubcategory;

  /// No description provided for @fieldBrand.
  ///
  /// In pt, this message translates to:
  /// **'Marca'**
  String get fieldBrand;

  /// No description provided for @fieldModel.
  ///
  /// In pt, this message translates to:
  /// **'Modelo'**
  String get fieldModel;

  /// No description provided for @fieldSection.
  ///
  /// In pt, this message translates to:
  /// **'Setor'**
  String get fieldSection;

  /// No description provided for @fieldLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get fieldLocation;

  /// No description provided for @fieldResponsible.
  ///
  /// In pt, this message translates to:
  /// **'Responsável'**
  String get fieldResponsible;

  /// No description provided for @fieldStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @fieldEntryDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de entrada'**
  String get fieldEntryDate;

  /// No description provided for @fieldAcquisitionDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de aquisição'**
  String get fieldAcquisitionDate;

  /// No description provided for @fieldValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get fieldValue;

  /// No description provided for @fieldSupplier.
  ///
  /// In pt, this message translates to:
  /// **'Fornecedor'**
  String get fieldSupplier;

  /// No description provided for @fieldUsefulLife.
  ///
  /// In pt, this message translates to:
  /// **'Vida útil'**
  String get fieldUsefulLife;

  /// No description provided for @fieldUsefulLifeMonths.
  ///
  /// In pt, this message translates to:
  /// **'Vida útil (meses)'**
  String get fieldUsefulLifeMonths;

  /// No description provided for @fieldLastMovement.
  ///
  /// In pt, this message translates to:
  /// **'Última movimentação'**
  String get fieldLastMovement;

  /// No description provided for @historyChange.
  ///
  /// In pt, this message translates to:
  /// **'Alteração'**
  String get historyChange;

  /// No description provided for @historyDeletion.
  ///
  /// In pt, this message translates to:
  /// **'Exclusão'**
  String get historyDeletion;

  /// No description provided for @historyRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restauração'**
  String get historyRestore;

  /// No description provided for @historyMovement.
  ///
  /// In pt, this message translates to:
  /// **'Movimentação'**
  String get historyMovement;

  /// No description provided for @historyNote.
  ///
  /// In pt, this message translates to:
  /// **'Obs.: {note}'**
  String historyNote(String note);

  /// No description provided for @activeDetailsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Ativo'**
  String get activeDetailsTitle;

  /// No description provided for @activeHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get activeHistory;

  /// No description provided for @activeHistoryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento registrado.'**
  String get activeHistoryEmpty;

  /// No description provided for @activeMove.
  ///
  /// In pt, this message translates to:
  /// **'Movimentar'**
  String get activeMove;

  /// No description provided for @activeWriteOff.
  ///
  /// In pt, this message translates to:
  /// **'Baixar'**
  String get activeWriteOff;

  /// No description provided for @activeUsefulLifeValue.
  ///
  /// In pt, this message translates to:
  /// **'{months, plural, =1{1 mês} other{{months} meses}}'**
  String activeUsefulLifeValue(int months);

  /// No description provided for @activeLastMovementValue.
  ///
  /// In pt, this message translates to:
  /// **'{date} por {author}'**
  String activeLastMovementValue(String date, String author);

  /// No description provided for @qrCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'QR Code'**
  String get qrCodeTitle;

  /// No description provided for @qrCodeSemantics.
  ///
  /// In pt, this message translates to:
  /// **'QR Code do Ativo {code}'**
  String qrCodeSemantics(String code);

  /// No description provided for @qrPrintLabel.
  ///
  /// In pt, this message translates to:
  /// **'Imprimir etiqueta'**
  String get qrPrintLabel;

  /// No description provided for @qrPrintError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível imprimir a etiqueta.'**
  String get qrPrintError;

  /// No description provided for @labelPdfTitle.
  ///
  /// In pt, this message translates to:
  /// **'Etiqueta {code}'**
  String labelPdfTitle(String code);

  /// No description provided for @activesSearch.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar ativos (nome, códigos, série...)'**
  String get activesSearch;

  /// No description provided for @activesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ativo encontrado.'**
  String get activesEmpty;

  /// No description provided for @activeFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Ativo'**
  String get activeFormEditTitle;

  /// No description provided for @activeFormCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Ativo'**
  String get activeFormCreateTitle;

  /// No description provided for @activeFormCreatedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Ativo {code} cadastrado com sucesso!'**
  String activeFormCreatedSuccess(String code);

  /// No description provided for @activeFormName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Ativo *'**
  String get activeFormName;

  /// No description provided for @activeFormType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo do Ativo *'**
  String get activeFormType;

  /// No description provided for @activeFormLocationReadOnly.
  ///
  /// In pt, this message translates to:
  /// **'Localização (alterar por Movimentação)'**
  String get activeFormLocationReadOnly;

  /// No description provided for @activeFormLocality.
  ///
  /// In pt, this message translates to:
  /// **'Localidade *'**
  String get activeFormLocality;

  /// No description provided for @activeFormSection.
  ///
  /// In pt, this message translates to:
  /// **'Setor *'**
  String get activeFormSection;

  /// No description provided for @activeFormEntryDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de entrada *'**
  String get activeFormEntryDate;

  /// No description provided for @activeFormUsefulLifeMin.
  ///
  /// In pt, this message translates to:
  /// **'Informe ao menos 1 mês.'**
  String get activeFormUsefulLifeMin;

  /// No description provided for @moveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Movimentar Ativo'**
  String get moveTitle;

  /// No description provided for @moveCurrentLocation.
  ///
  /// In pt, this message translates to:
  /// **'Atual: {location}'**
  String moveCurrentLocation(String location);

  /// No description provided for @moveMovement.
  ///
  /// In pt, this message translates to:
  /// **'Movimentação *'**
  String get moveMovement;

  /// No description provided for @moveStatusAfter.
  ///
  /// In pt, this message translates to:
  /// **'Status após a movimentação: '**
  String get moveStatusAfter;

  /// No description provided for @moveDestinationLocality.
  ///
  /// In pt, this message translates to:
  /// **'Localidade de destino'**
  String get moveDestinationLocality;

  /// No description provided for @moveDestinationSectionRequired.
  ///
  /// In pt, this message translates to:
  /// **'Setor de destino *'**
  String get moveDestinationSectionRequired;

  /// No description provided for @moveDestinationSectionOptional.
  ///
  /// In pt, this message translates to:
  /// **'Setor de destino (opcional)'**
  String get moveDestinationSectionOptional;

  /// No description provided for @moveObservation.
  ///
  /// In pt, this message translates to:
  /// **'Observação'**
  String get moveObservation;

  /// No description provided for @moveObservationRequired.
  ///
  /// In pt, this message translates to:
  /// **'Observação *'**
  String get moveObservationRequired;

  /// No description provided for @moveSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Registrar movimentação'**
  String get moveSubmit;

  /// No description provided for @moveSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Movimentação registrada com sucesso!'**
  String get moveSuccess;

  /// No description provided for @moveSelectSection.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o setor de destino.'**
  String get moveSelectSection;

  /// No description provided for @moveSelectDifferentSection.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um setor diferente do atual.'**
  String get moveSelectDifferentSection;

  /// No description provided for @writeOffTitle.
  ///
  /// In pt, this message translates to:
  /// **'Baixar Ativo'**
  String get writeOffTitle;

  /// No description provided for @writeOffConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar baixa'**
  String get writeOffConfirmTitle;

  /// No description provided for @writeOffConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'A baixa é definitiva: o ativo {code} não poderá mais ser movimentado nem alterado. Deseja continuar?'**
  String writeOffConfirmMessage(String code);

  /// No description provided for @writeOffSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Baixa registrada!'**
  String get writeOffSuccess;

  /// No description provided for @writeOffReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo da baixa *'**
  String get writeOffReason;

  /// No description provided for @writeOffSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Registrar baixa'**
  String get writeOffSubmit;

  /// No description provided for @dashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total de ativos'**
  String get dashboardTotal;

  /// No description provided for @dashboardTotalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem baixados'**
  String get dashboardTotalSubtitle;

  /// No description provided for @dashboardOfTotal.
  ///
  /// In pt, this message translates to:
  /// **'{percent} do total'**
  String dashboardOfTotal(String percent);

  /// No description provided for @dashboardAssetValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor patrimonial'**
  String get dashboardAssetValue;

  /// No description provided for @dashboardWithoutValue.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 sem valor} other{{count} sem valor}}'**
  String dashboardWithoutValue(int count);

  /// No description provided for @dashboardByStatus.
  ///
  /// In pt, this message translates to:
  /// **'Por status'**
  String get dashboardByStatus;

  /// No description provided for @dashboardByLocation.
  ///
  /// In pt, this message translates to:
  /// **'Por localidade'**
  String get dashboardByLocation;

  /// No description provided for @dashboardTopTypes.
  ///
  /// In pt, this message translates to:
  /// **'Top 5 por tipo'**
  String get dashboardTopTypes;

  /// No description provided for @dashboardEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ativo cadastrado'**
  String get dashboardEmpty;

  /// No description provided for @reportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios'**
  String get reportsTitle;

  /// No description provided for @typePrefixValue.
  ///
  /// In pt, this message translates to:
  /// **'Prefixo: {prefix}'**
  String typePrefixValue(String prefix);

  /// No description provided for @typePrefix.
  ///
  /// In pt, this message translates to:
  /// **'Prefixo'**
  String get typePrefix;

  /// No description provided for @typeFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Tipo'**
  String get typeFormEditTitle;

  /// No description provided for @typeFormCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Tipo'**
  String get typeFormCreateTitle;

  /// No description provided for @typesSearch.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar tipo'**
  String get typesSearch;

  /// No description provided for @supplierFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Fornecedor'**
  String get supplierFormEditTitle;

  /// No description provided for @supplierFormCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Fornecedor'**
  String get supplierFormCreateTitle;

  /// No description provided for @supplierName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Fornecedor'**
  String get supplierName;

  /// No description provided for @supplierCnpj.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ do Fornecedor'**
  String get supplierCnpj;

  /// No description provided for @supplierCnpjInvalid.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ inválido.'**
  String get supplierCnpjInvalid;

  /// No description provided for @supplierPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone do Fornecedor'**
  String get supplierPhone;

  /// No description provided for @supplierPhoneInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um telefone válido com DDD (10 ou 11 dígitos).'**
  String get supplierPhoneInvalid;

  /// No description provided for @suppliersSearch.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar Fornecedor'**
  String get suppliersSearch;

  /// No description provided for @locationFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Localidade'**
  String get locationFormEditTitle;

  /// No description provided for @locationFormCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Localidade'**
  String get locationFormCreateTitle;

  /// No description provided for @sectionFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Setor'**
  String get sectionFormEditTitle;

  /// No description provided for @sectionFormCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Setor'**
  String get sectionFormCreateTitle;

  /// No description provided for @locationDetailsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da Localidade'**
  String get locationDetailsTitle;

  /// No description provided for @locationSections.
  ///
  /// In pt, this message translates to:
  /// **'Setores'**
  String get locationSections;

  /// No description provided for @locationSectionsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum setor cadastrado.'**
  String get locationSectionsEmpty;

  /// No description provided for @locationsSearch.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar localidade'**
  String get locationsSearch;

  /// No description provided for @provisionalPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Senha provisória'**
  String get provisionalPasswordTitle;

  /// No description provided for @provisionalPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Anote ou copie a senha abaixo e entregue ao usuário. Ela não será exibida novamente.'**
  String get provisionalPasswordHint;

  /// No description provided for @provisionalPasswordCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get provisionalPasswordCopy;

  /// No description provided for @provisionalPasswordCopied.
  ///
  /// In pt, this message translates to:
  /// **'Senha copiada.'**
  String get provisionalPasswordCopied;

  /// No description provided for @provisionalPasswordValidUntil.
  ///
  /// In pt, this message translates to:
  /// **'Válida até {date}'**
  String provisionalPasswordValidUntil(String date);

  /// No description provided for @userCreatedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Usuário cadastrado'**
  String get userCreatedTitle;

  /// No description provided for @userResetPassword.
  ///
  /// In pt, this message translates to:
  /// **'Redefinir senha'**
  String get userResetPassword;

  /// No description provided for @userResetPasswordMessage.
  ///
  /// In pt, this message translates to:
  /// **'Uma nova senha provisória será gerada para {name} e todas as sessões dele serão encerradas. Deseja continuar?'**
  String userResetPasswordMessage(String name);

  /// No description provided for @userResetPasswordFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'o usuário'**
  String get userResetPasswordFallbackName;

  /// No description provided for @userResetConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Redefinir'**
  String get userResetConfirm;

  /// No description provided for @userPasswordResetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Senha redefinida'**
  String get userPasswordResetTitle;

  /// No description provided for @userFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar Usuário'**
  String get userFormEditTitle;

  /// No description provided for @userFormCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Usuário'**
  String get userFormCreateTitle;

  /// No description provided for @userEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get userEmail;

  /// No description provided for @userEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido.'**
  String get userEmailInvalid;

  /// No description provided for @usersSearch.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar usuário (nome ou e-mail)'**
  String get usersSearch;

  /// No description provided for @usersStatusFilter.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get usersStatusFilter;

  /// No description provided for @usersActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativos'**
  String get usersActive;

  /// No description provided for @usersInactive.
  ///
  /// In pt, this message translates to:
  /// **'Inativos'**
  String get usersInactive;

  /// No description provided for @usersEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum usuário encontrado.'**
  String get usersEmpty;

  /// No description provided for @activesFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar ativos.'**
  String get activesFetchError;

  /// No description provided for @activeFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar ativo.'**
  String get activeFetchError;

  /// No description provided for @activeCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao cadastrar ativo.'**
  String get activeCreateError;

  /// No description provided for @activeUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar ativo.'**
  String get activeUpdateError;

  /// No description provided for @historyFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar histórico.'**
  String get historyFetchError;

  /// No description provided for @movementsFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar movimentações.'**
  String get movementsFetchError;

  /// No description provided for @movementCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao registrar movimentação.'**
  String get movementCreateError;

  /// No description provided for @writeOffError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao registrar baixa.'**
  String get writeOffError;

  /// No description provided for @loginError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao realizar login.'**
  String get loginError;

  /// No description provided for @changePasswordError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao trocar a senha.'**
  String get changePasswordError;

  /// No description provided for @logoutError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao realizar o logout.'**
  String get logoutError;

  /// No description provided for @categoriesFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar categorias.'**
  String get categoriesFetchError;

  /// No description provided for @subcategoriesFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar subcategorias.'**
  String get subcategoriesFetchError;

  /// No description provided for @dashboardSummaryFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar o resumo do dashboard.'**
  String get dashboardSummaryFetchError;

  /// No description provided for @dashboardByLocationFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar ativos por localidade.'**
  String get dashboardByLocationFetchError;

  /// No description provided for @locationsFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar localidades.'**
  String get locationsFetchError;

  /// No description provided for @locationCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao cadastrar localidade.'**
  String get locationCreateError;

  /// No description provided for @locationUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar localidade.'**
  String get locationUpdateError;

  /// No description provided for @sectionsFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar setores.'**
  String get sectionsFetchError;

  /// No description provided for @sectionCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao cadastrar setor.'**
  String get sectionCreateError;

  /// No description provided for @sectionUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar setor.'**
  String get sectionUpdateError;

  /// No description provided for @suppliersFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar fornecedores.'**
  String get suppliersFetchError;

  /// No description provided for @supplierCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao criar fornecedor.'**
  String get supplierCreateError;

  /// No description provided for @supplierUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar fornecedor.'**
  String get supplierUpdateError;

  /// No description provided for @typesFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar tipos.'**
  String get typesFetchError;

  /// No description provided for @typeCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao cadastrar tipo.'**
  String get typeCreateError;

  /// No description provided for @typeUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar tipo.'**
  String get typeUpdateError;

  /// No description provided for @usersFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar usuários.'**
  String get usersFetchError;

  /// No description provided for @userFetchError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao buscar usuário.'**
  String get userFetchError;

  /// No description provided for @userCreateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao cadastrar usuário.'**
  String get userCreateError;

  /// No description provided for @userUpdateError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar usuário.'**
  String get userUpdateError;

  /// No description provided for @userResetPasswordError.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao redefinir senha.'**
  String get userResetPasswordError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
