// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appHeader => 'Gestão de ativos';

  @override
  String get commonRequiredField => 'Campo obrigatório.';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonRegister => 'Cadastrar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonActive => 'Ativo';

  @override
  String get commonDisabled => 'Desativado';

  @override
  String get commonName => 'Nome';

  @override
  String get commonAll => 'Todos';

  @override
  String get commonProfile => 'Perfil';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonLogout => 'Sair';

  @override
  String get commonUpdatedSuccess => 'Atualizado com sucesso!';

  @override
  String get commonCreatedSuccess => 'Cadastro realizado com sucesso!';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonLoadError => 'Ocorreu um erro ao carregar as informações.';

  @override
  String get commonLoadMore => 'Carregar mais';

  @override
  String get commonInvalidDate => 'Data inválida.';

  @override
  String get commonEmptyValue => '—';

  @override
  String get drawerDashboard => 'Dashboard';

  @override
  String get drawerActives => 'Ativos';

  @override
  String get drawerTypes => 'Tipos';

  @override
  String get drawerSuppliers => 'Fornecedores';

  @override
  String get drawerLocations => 'Localidades';

  @override
  String get drawerUsers => 'Usuários';

  @override
  String get drawerSettings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageDescription => 'Escolha o idioma do aplicativo.';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageSpanish => 'Español';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailInvalid => 'Email inválido';

  @override
  String get authPassword => 'Senha';

  @override
  String get authPasswordMinLength => 'Senha deve ter no mínimo 6 caracteres';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authLoginFailed => 'Falha ao realizar o login';

  @override
  String get authLoginSuccess => 'Login realizado com sucesso!';

  @override
  String get authForgotPassword => 'Esqueci minha senha';

  @override
  String get changePasswordTitle => 'Trocar senha';

  @override
  String get changePasswordDescription =>
      'Você entrou com uma senha provisória. Defina uma nova senha para continuar.';

  @override
  String get changePasswordCurrent => 'Senha atual (provisória)';

  @override
  String get changePasswordNew => 'Nova senha';

  @override
  String get changePasswordLength => 'A senha deve ter de 8 a 128 caracteres';

  @override
  String get changePasswordSameAsCurrent =>
      'A nova senha deve ser diferente da atual';

  @override
  String get changePasswordConfirm => 'Confirmar nova senha';

  @override
  String get changePasswordMismatch => 'As senhas não conferem';

  @override
  String get changePasswordSave => 'Salvar nova senha';

  @override
  String get changePasswordSuccess => 'Senha alterada com sucesso!';

  @override
  String get activeStatusAvailable => 'Disponível';

  @override
  String get activeStatusInUse => 'Em uso';

  @override
  String get activeStatusInMaintenance => 'Em manutenção';

  @override
  String get activeStatusWrittenOff => 'Baixado';

  @override
  String get movementEntry => 'Entrada';

  @override
  String get movementTransfer => 'Transferência';

  @override
  String get movementCheckout => 'Saída para uso';

  @override
  String get movementReturn => 'Devolução';

  @override
  String get movementSendToMaintenance => 'Envio para manutenção';

  @override
  String get movementReturnFromMaintenance => 'Retorno de manutenção';

  @override
  String get movementWriteOff => 'Baixa';

  @override
  String get profileAdministrator => 'Administrador';

  @override
  String get profileManager => 'Gestor';

  @override
  String get profileOperational => 'Operacional';

  @override
  String get profileViewer => 'Consulta';

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldInternalCode => 'Código interno';

  @override
  String get fieldSapCode => 'Código SAP';

  @override
  String get fieldSerialNumber => 'Número de série';

  @override
  String get fieldPatrimony => 'Patrimônio';

  @override
  String get fieldType => 'Tipo';

  @override
  String get fieldCategory => 'Categoria';

  @override
  String get fieldSubcategory => 'Subcategoria';

  @override
  String get fieldBrand => 'Marca';

  @override
  String get fieldModel => 'Modelo';

  @override
  String get fieldSection => 'Setor';

  @override
  String get fieldLocation => 'Localização';

  @override
  String get fieldResponsible => 'Responsável';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldEntryDate => 'Data de entrada';

  @override
  String get fieldAcquisitionDate => 'Data de aquisição';

  @override
  String get fieldValue => 'Valor';

  @override
  String get fieldSupplier => 'Fornecedor';

  @override
  String get fieldUsefulLife => 'Vida útil';

  @override
  String get fieldUsefulLifeMonths => 'Vida útil (meses)';

  @override
  String get fieldLastMovement => 'Última movimentação';

  @override
  String get historyChange => 'Alteração';

  @override
  String get historyDeletion => 'Exclusão';

  @override
  String get historyRestore => 'Restauração';

  @override
  String get historyMovement => 'Movimentação';

  @override
  String historyNote(String note) {
    return 'Obs.: $note';
  }

  @override
  String get activeDetailsTitle => 'Detalhes do Ativo';

  @override
  String get activeHistory => 'Histórico';

  @override
  String get activeHistoryEmpty => 'Nenhum evento registrado.';

  @override
  String get activeMove => 'Movimentar';

  @override
  String get activeWriteOff => 'Baixar';

  @override
  String activeUsefulLifeValue(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mês',
    );
    return '$_temp0';
  }

  @override
  String activeLastMovementValue(String date, String author) {
    return '$date por $author';
  }

  @override
  String get qrCodeTitle => 'QR Code';

  @override
  String qrCodeSemantics(String code) {
    return 'QR Code do Ativo $code';
  }

  @override
  String get qrPrintLabel => 'Imprimir etiqueta';

  @override
  String get qrPrintError => 'Não foi possível imprimir a etiqueta.';

  @override
  String labelPdfTitle(String code) {
    return 'Etiqueta $code';
  }

  @override
  String get activesSearch => 'Pesquisar ativos (nome, códigos, série...)';

  @override
  String get activesEmpty => 'Nenhum ativo encontrado.';

  @override
  String get activeFormEditTitle => 'Editar Ativo';

  @override
  String get activeFormCreateTitle => 'Cadastrar Ativo';

  @override
  String activeFormCreatedSuccess(String code) {
    return 'Ativo $code cadastrado com sucesso!';
  }

  @override
  String get activeFormName => 'Nome do Ativo *';

  @override
  String get activeFormType => 'Tipo do Ativo *';

  @override
  String get activeFormLocationReadOnly =>
      'Localização (alterar por Movimentação)';

  @override
  String get activeFormLocality => 'Localidade *';

  @override
  String get activeFormSection => 'Setor *';

  @override
  String get activeFormEntryDate => 'Data de entrada *';

  @override
  String get activeFormUsefulLifeMin => 'Informe ao menos 1 mês.';

  @override
  String get moveTitle => 'Movimentar Ativo';

  @override
  String moveCurrentLocation(String location) {
    return 'Atual: $location';
  }

  @override
  String get moveMovement => 'Movimentação *';

  @override
  String get moveStatusAfter => 'Status após a movimentação: ';

  @override
  String get moveDestinationLocality => 'Localidade de destino';

  @override
  String get moveDestinationSectionRequired => 'Setor de destino *';

  @override
  String get moveDestinationSectionOptional => 'Setor de destino (opcional)';

  @override
  String get moveObservation => 'Observação';

  @override
  String get moveObservationRequired => 'Observação *';

  @override
  String get moveSubmit => 'Registrar movimentação';

  @override
  String get moveSuccess => 'Movimentação registrada com sucesso!';

  @override
  String get moveSelectSection => 'Selecione o setor de destino.';

  @override
  String get moveSelectDifferentSection =>
      'Selecione um setor diferente do atual.';

  @override
  String get writeOffTitle => 'Baixar Ativo';

  @override
  String get writeOffConfirmTitle => 'Confirmar baixa';

  @override
  String writeOffConfirmMessage(String code) {
    return 'A baixa é definitiva: o ativo $code não poderá mais ser movimentado nem alterado. Deseja continuar?';
  }

  @override
  String get writeOffSuccess => 'Baixa registrada!';

  @override
  String get writeOffReason => 'Motivo da baixa *';

  @override
  String get writeOffSubmit => 'Registrar baixa';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardTotal => 'Total de ativos';

  @override
  String get dashboardTotalSubtitle => 'Sem baixados';

  @override
  String dashboardOfTotal(String percent) {
    return '$percent do total';
  }

  @override
  String get dashboardAssetValue => 'Valor patrimonial';

  @override
  String dashboardWithoutValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sem valor',
      one: '1 sem valor',
    );
    return '$_temp0';
  }

  @override
  String get dashboardByStatus => 'Por status';

  @override
  String get dashboardByLocation => 'Por localidade';

  @override
  String get dashboardTopTypes => 'Top 5 por tipo';

  @override
  String get dashboardEmpty => 'Nenhum ativo cadastrado';

  @override
  String get reportsTitle => 'Relatórios';

  @override
  String typePrefixValue(String prefix) {
    return 'Prefixo: $prefix';
  }

  @override
  String get typePrefix => 'Prefixo';

  @override
  String get typeFormEditTitle => 'Editar Tipo';

  @override
  String get typeFormCreateTitle => 'Cadastrar Tipo';

  @override
  String get typesSearch => 'Pesquisar tipo (nome ou prefixo)';

  @override
  String get typesEmpty => 'Nenhum tipo encontrado.';

  @override
  String get supplierFormEditTitle => 'Editar Fornecedor';

  @override
  String get supplierFormCreateTitle => 'Cadastrar Fornecedor';

  @override
  String get supplierName => 'Nome do Fornecedor';

  @override
  String get supplierCnpj => 'CNPJ do Fornecedor';

  @override
  String get supplierCnpjInvalid => 'CNPJ inválido.';

  @override
  String get supplierPhone => 'Telefone do Fornecedor';

  @override
  String get supplierPhoneInvalid =>
      'Informe um telefone válido com DDD (10 ou 11 dígitos).';

  @override
  String get suppliersSearch => 'Pesquisar fornecedor (razão social ou CNPJ)';

  @override
  String get suppliersEmpty => 'Nenhum fornecedor encontrado.';

  @override
  String get locationFormEditTitle => 'Editar Localidade';

  @override
  String get locationFormCreateTitle => 'Cadastrar Localidade';

  @override
  String get sectionFormEditTitle => 'Editar Setor';

  @override
  String get sectionFormCreateTitle => 'Cadastrar Setor';

  @override
  String get locationDetailsTitle => 'Detalhes da Localidade';

  @override
  String get locationSections => 'Setores';

  @override
  String get locationSectionsEmpty => 'Nenhum setor cadastrado.';

  @override
  String get locationsSearch => 'Pesquisar localidade (nome)';

  @override
  String get locationsEmpty => 'Nenhuma localidade encontrada.';

  @override
  String get provisionalPasswordTitle => 'Senha provisória';

  @override
  String get provisionalPasswordHint =>
      'Anote ou copie a senha abaixo e entregue ao usuário. Ela não será exibida novamente.';

  @override
  String get provisionalPasswordCopy => 'Copiar';

  @override
  String get provisionalPasswordCopied => 'Senha copiada.';

  @override
  String provisionalPasswordValidUntil(String date) {
    return 'Válida até $date';
  }

  @override
  String get userCreatedTitle => 'Usuário cadastrado';

  @override
  String get userResetPassword => 'Redefinir senha';

  @override
  String userResetPasswordMessage(String name) {
    return 'Uma nova senha provisória será gerada para $name e todas as sessões dele serão encerradas. Deseja continuar?';
  }

  @override
  String get userResetPasswordFallbackName => 'o usuário';

  @override
  String get userResetConfirm => 'Redefinir';

  @override
  String get userPasswordResetTitle => 'Senha redefinida';

  @override
  String get userFormEditTitle => 'Editar Usuário';

  @override
  String get userFormCreateTitle => 'Cadastrar Usuário';

  @override
  String get userEmail => 'E-mail';

  @override
  String get userEmailInvalid => 'E-mail inválido.';

  @override
  String get usersSearch => 'Pesquisar usuário (nome ou e-mail)';

  @override
  String get usersStatusFilter => 'Situação';

  @override
  String get usersActive => 'Ativos';

  @override
  String get usersInactive => 'Inativos';

  @override
  String get usersEmpty => 'Nenhum usuário encontrado.';

  @override
  String get activesFetchError => 'Falha ao buscar ativos.';

  @override
  String get activeFetchError => 'Falha ao buscar ativo.';

  @override
  String get activeCreateError => 'Falha ao cadastrar ativo.';

  @override
  String get activeUpdateError => 'Falha ao atualizar ativo.';

  @override
  String get historyFetchError => 'Falha ao buscar histórico.';

  @override
  String get movementsFetchError => 'Falha ao buscar movimentações.';

  @override
  String get movementCreateError => 'Falha ao registrar movimentação.';

  @override
  String get writeOffError => 'Falha ao registrar baixa.';

  @override
  String get loginError => 'Falha ao realizar login.';

  @override
  String get changePasswordError => 'Falha ao trocar a senha.';

  @override
  String get logoutError => 'Falha ao realizar o logout.';

  @override
  String get categoriesFetchError => 'Falha ao buscar categorias.';

  @override
  String get subcategoriesFetchError => 'Falha ao buscar subcategorias.';

  @override
  String get dashboardSummaryFetchError =>
      'Falha ao buscar o resumo do dashboard.';

  @override
  String get dashboardByLocationFetchError =>
      'Falha ao buscar ativos por localidade.';

  @override
  String get locationsFetchError => 'Falha ao buscar localidades.';

  @override
  String get locationCreateError => 'Falha ao cadastrar localidade.';

  @override
  String get locationUpdateError => 'Falha ao atualizar localidade.';

  @override
  String get sectionsFetchError => 'Falha ao buscar setores.';

  @override
  String get sectionCreateError => 'Falha ao cadastrar setor.';

  @override
  String get sectionUpdateError => 'Falha ao atualizar setor.';

  @override
  String get suppliersFetchError => 'Falha ao buscar fornecedores.';

  @override
  String get supplierCreateError => 'Falha ao criar fornecedor.';

  @override
  String get supplierUpdateError => 'Falha ao atualizar fornecedor.';

  @override
  String get typesFetchError => 'Falha ao buscar tipos.';

  @override
  String get typeCreateError => 'Falha ao cadastrar tipo.';

  @override
  String get typeUpdateError => 'Falha ao atualizar tipo.';

  @override
  String get usersFetchError => 'Falha ao buscar usuários.';

  @override
  String get userFetchError => 'Falha ao buscar usuário.';

  @override
  String get userCreateError => 'Falha ao cadastrar usuário.';

  @override
  String get userUpdateError => 'Falha ao atualizar usuário.';

  @override
  String get userResetPasswordError => 'Falha ao redefinir senha.';

  @override
  String get typeIsKit => 'É Kit';

  @override
  String get typeIsKitHint =>
      'Ativos deste tipo aceitam itens associados, que acompanham as movimentações.';

  @override
  String get typeKitTag => 'Kit';

  @override
  String get kitItemsTitle => 'Itens do Kit';

  @override
  String get kitItemsEmpty => 'Nenhum item associado.';

  @override
  String get kitAddItem => 'Adicionar item';

  @override
  String get kitAddItemTitle => 'Adicionar item ao Kit';

  @override
  String get kitAddItemSearch => 'Pesquisar ativo';

  @override
  String get kitAddItemEmpty =>
      'Nenhum ativo disponível no mesmo status do Kit.';

  @override
  String get kitAddItemSuccess => 'Item adicionado ao Kit!';

  @override
  String get kitRemoveItem => 'Remover do Kit';

  @override
  String get kitRemoveItemSuccess => 'Item removido do Kit!';

  @override
  String get kitRemoveConfirmTitle => 'Remover item do Kit';

  @override
  String kitRemoveConfirmMessage(String code) {
    return 'O ativo $code deixará de acompanhar as movimentações do Kit. Deseja continuar?';
  }

  @override
  String get kitItemDifferentStatus =>
      'Status diferente do Kit: não acompanha as movimentações.';

  @override
  String kitBelongsTo(String code, String name) {
    return 'Pertence ao Kit $code · $name';
  }

  @override
  String get kitBelongsToHint =>
      'Este item acompanha as movimentações do Kit. Para movimentá-lo ou baixá-lo sozinho, remova-o do Kit.';

  @override
  String get kitOpen => 'Abrir Kit';

  @override
  String get kitItemAddError => 'Falha ao adicionar item ao Kit.';

  @override
  String get kitItemRemoveError => 'Falha ao remover item do Kit.';

  @override
  String moveKitItemsFollow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens acompanharão a movimentação.',
      one: '1 item acompanhará a movimentação.',
      zero: 'Nenhum item acompanhará a movimentação.',
    );
    return '$_temp0';
  }

  @override
  String get moveKitItemsLeftBehind => 'Não acompanharão:';

  @override
  String moveSuccessKitLeftBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens não acompanharam o Kit.',
      one: '1 item não acompanhou o Kit.',
    );
    return 'Movimentação registrada. $_temp0';
  }
}
