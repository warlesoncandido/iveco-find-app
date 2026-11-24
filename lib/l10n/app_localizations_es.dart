// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appHeader => 'Gestión de activos';

  @override
  String get commonRequiredField => 'Campo obligatorio.';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonRegister => 'Registrar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonActive => 'Activo';

  @override
  String get commonDisabled => 'Desactivado';

  @override
  String get commonName => 'Nombre';

  @override
  String get commonAll => 'Todos';

  @override
  String get commonProfile => 'Perfil';

  @override
  String get commonStatus => 'Estado';

  @override
  String get commonLogout => 'Salir';

  @override
  String get commonUpdatedSuccess => '¡Actualizado con éxito!';

  @override
  String get commonCreatedSuccess => '¡Registro realizado con éxito!';

  @override
  String get commonRetry => 'Intentar de nuevo';

  @override
  String get commonLoadError => 'Ocurrió un error al cargar la información.';

  @override
  String get commonLoadMore => 'Cargar más';

  @override
  String get commonInvalidDate => 'Fecha inválida.';

  @override
  String get commonEmptyValue => '—';

  @override
  String get drawerDashboard => 'Panel';

  @override
  String get drawerActives => 'Activos';

  @override
  String get drawerTypes => 'Tipos';

  @override
  String get drawerSuppliers => 'Proveedores';

  @override
  String get drawerLocations => 'Localidades';

  @override
  String get drawerUsers => 'Usuarios';

  @override
  String get drawerSettings => 'Configuración';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageDescription => 'Elige el idioma de la aplicación.';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageSpanish => 'Español';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authEmailInvalid => 'Correo electrónico inválido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authSignIn => 'Ingresar';

  @override
  String get authLoginFailed => 'Error al iniciar sesión';

  @override
  String get authLoginSuccess => '¡Inicio de sesión exitoso!';

  @override
  String get authForgotPassword => 'Olvidé mi contraseña';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get changePasswordDescription =>
      'Ingresaste con una contraseña provisional. Define una nueva contraseña para continuar.';

  @override
  String get changePasswordCurrent => 'Contraseña actual (provisional)';

  @override
  String get changePasswordNew => 'Nueva contraseña';

  @override
  String get changePasswordLength =>
      'La contraseña debe tener entre 8 y 128 caracteres';

  @override
  String get changePasswordSameAsCurrent =>
      'La nueva contraseña debe ser diferente de la actual';

  @override
  String get changePasswordConfirm => 'Confirmar nueva contraseña';

  @override
  String get changePasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get changePasswordSave => 'Guardar nueva contraseña';

  @override
  String get changePasswordSuccess => '¡Contraseña cambiada con éxito!';

  @override
  String get activeStatusAvailable => 'Disponible';

  @override
  String get activeStatusInUse => 'En uso';

  @override
  String get activeStatusInMaintenance => 'En mantenimiento';

  @override
  String get activeStatusWrittenOff => 'Dado de baja';

  @override
  String get movementEntry => 'Entrada';

  @override
  String get movementTransfer => 'Transferencia';

  @override
  String get movementCheckout => 'Salida para uso';

  @override
  String get movementReturn => 'Devolución';

  @override
  String get movementSendToMaintenance => 'Envío a mantenimiento';

  @override
  String get movementReturnFromMaintenance => 'Regreso de mantenimiento';

  @override
  String get movementWriteOff => 'Baja';

  @override
  String get profileAdministrator => 'Administrador';

  @override
  String get profileManager => 'Gestor';

  @override
  String get profileOperational => 'Operativo';

  @override
  String get profileViewer => 'Consulta';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldInternalCode => 'Código interno';

  @override
  String get fieldSapCode => 'Código SAP';

  @override
  String get fieldSerialNumber => 'Número de serie';

  @override
  String get fieldPatrimony => 'Patrimonio';

  @override
  String get fieldType => 'Tipo';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get fieldSubcategory => 'Subcategoría';

  @override
  String get fieldBrand => 'Marca';

  @override
  String get fieldModel => 'Modelo';

  @override
  String get fieldSection => 'Sector';

  @override
  String get fieldLocation => 'Ubicación';

  @override
  String get fieldResponsible => 'Responsable';

  @override
  String get fieldStatus => 'Estado';

  @override
  String get fieldEntryDate => 'Fecha de entrada';

  @override
  String get fieldAcquisitionDate => 'Fecha de adquisición';

  @override
  String get fieldValue => 'Valor';

  @override
  String get fieldSupplier => 'Proveedor';

  @override
  String get fieldUsefulLife => 'Vida útil';

  @override
  String get fieldUsefulLifeMonths => 'Vida útil (meses)';

  @override
  String get fieldLastMovement => 'Último movimiento';

  @override
  String get historyChange => 'Modificación';

  @override
  String get historyDeletion => 'Eliminación';

  @override
  String get historyRestore => 'Restauración';

  @override
  String get historyMovement => 'Movimiento';

  @override
  String historyNote(String note) {
    return 'Obs.: $note';
  }

  @override
  String get activeDetailsTitle => 'Detalles del activo';

  @override
  String get activeHistory => 'Historial';

  @override
  String get activeHistoryEmpty => 'Ningún evento registrado.';

  @override
  String get activeMove => 'Mover';

  @override
  String get activeWriteOff => 'Dar de baja';

  @override
  String activeUsefulLifeValue(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String activeLastMovementValue(String date, String author) {
    return '$date por $author';
  }

  @override
  String get qrCodeTitle => 'Código QR';

  @override
  String qrCodeSemantics(String code) {
    return 'Código QR del activo $code';
  }

  @override
  String get qrPrintLabel => 'Imprimir etiqueta';

  @override
  String get qrPrintError => 'No fue posible imprimir la etiqueta.';

  @override
  String labelPdfTitle(String code) {
    return 'Etiqueta $code';
  }

  @override
  String get activesSearch => 'Buscar activos (nombre, códigos, serie...)';

  @override
  String get activesEmpty => 'Ningún activo encontrado.';

  @override
  String get activeFormEditTitle => 'Editar activo';

  @override
  String get activeFormCreateTitle => 'Registrar activo';

  @override
  String activeFormCreatedSuccess(String code) {
    return '¡Activo $code registrado con éxito!';
  }

  @override
  String get activeFormName => 'Nombre del activo *';

  @override
  String get activeFormType => 'Tipo de activo *';

  @override
  String get activeFormLocationReadOnly =>
      'Ubicación (cambiar mediante un movimiento)';

  @override
  String get activeFormLocality => 'Localidad *';

  @override
  String get activeFormSection => 'Sector *';

  @override
  String get activeFormEntryDate => 'Fecha de entrada *';

  @override
  String get activeFormUsefulLifeMin => 'Indica al menos 1 mes.';

  @override
  String get moveTitle => 'Mover activo';

  @override
  String moveCurrentLocation(String location) {
    return 'Actual: $location';
  }

  @override
  String get moveMovement => 'Movimiento *';

  @override
  String get moveStatusAfter => 'Estado después del movimiento: ';

  @override
  String get moveDestinationLocality => 'Localidad de destino';

  @override
  String get moveDestinationSectionRequired => 'Sector de destino *';

  @override
  String get moveDestinationSectionOptional => 'Sector de destino (opcional)';

  @override
  String get moveObservation => 'Observación';

  @override
  String get moveObservationRequired => 'Observación *';

  @override
  String get moveSubmit => 'Registrar movimiento';

  @override
  String get moveSuccess => '¡Movimiento registrado con éxito!';

  @override
  String get moveSelectSection => 'Selecciona el sector de destino.';

  @override
  String get moveSelectDifferentSection =>
      'Selecciona un sector diferente del actual.';

  @override
  String get writeOffTitle => 'Dar de baja el activo';

  @override
  String get writeOffConfirmTitle => 'Confirmar baja';

  @override
  String writeOffConfirmMessage(String code) {
    return 'La baja es definitiva: el activo $code ya no podrá moverse ni modificarse. ¿Deseas continuar?';
  }

  @override
  String get writeOffSuccess => '¡Baja registrada!';

  @override
  String get writeOffReason => 'Motivo de la baja *';

  @override
  String get writeOffSubmit => 'Registrar baja';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get dashboardTotal => 'Total de activos';

  @override
  String get dashboardTotalSubtitle => 'Sin dados de baja';

  @override
  String dashboardOfTotal(String percent) {
    return '$percent del total';
  }

  @override
  String get dashboardAssetValue => 'Valor patrimonial';

  @override
  String dashboardWithoutValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sin valor',
      one: '1 sin valor',
    );
    return '$_temp0';
  }

  @override
  String get dashboardByStatus => 'Por estado';

  @override
  String get dashboardByLocation => 'Por localidad';

  @override
  String get dashboardTopTypes => 'Top 5 por tipo';

  @override
  String get dashboardEmpty => 'Ningún activo registrado';

  @override
  String get reportsTitle => 'Informes';

  @override
  String typePrefixValue(String prefix) {
    return 'Prefijo: $prefix';
  }

  @override
  String get typePrefix => 'Prefijo';

  @override
  String get typeFormEditTitle => 'Editar tipo';

  @override
  String get typeFormCreateTitle => 'Registrar tipo';

  @override
  String get typesSearch => 'Buscar tipo (nombre o prefijo)';

  @override
  String get typesEmpty => 'Ningún tipo encontrado.';

  @override
  String get supplierFormEditTitle => 'Editar proveedor';

  @override
  String get supplierFormCreateTitle => 'Registrar proveedor';

  @override
  String get supplierName => 'Nombre del proveedor';

  @override
  String get supplierCnpj => 'CNPJ del proveedor';

  @override
  String get supplierCnpjInvalid => 'CNPJ inválido.';

  @override
  String get supplierPhone => 'Teléfono del proveedor';

  @override
  String get supplierPhoneInvalid =>
      'Indica un teléfono válido con código de área (10 u 11 dígitos).';

  @override
  String get suppliersSearch => 'Buscar proveedor (razón social o CNPJ)';

  @override
  String get suppliersEmpty => 'Ningún proveedor encontrado.';

  @override
  String get locationFormEditTitle => 'Editar localidad';

  @override
  String get locationFormCreateTitle => 'Registrar localidad';

  @override
  String get sectionFormEditTitle => 'Editar sector';

  @override
  String get sectionFormCreateTitle => 'Registrar sector';

  @override
  String get locationDetailsTitle => 'Detalles de la localidad';

  @override
  String get locationSections => 'Sectores';

  @override
  String get locationSectionsEmpty => 'Ningún sector registrado.';

  @override
  String get locationsSearch => 'Buscar localidad (nombre)';

  @override
  String get locationsEmpty => 'Ninguna localidad encontrada.';

  @override
  String get provisionalPasswordTitle => 'Contraseña provisional';

  @override
  String get provisionalPasswordHint =>
      'Anota o copia la contraseña de abajo y entrégasela al usuario. No se volverá a mostrar.';

  @override
  String get provisionalPasswordCopy => 'Copiar';

  @override
  String get provisionalPasswordCopied => 'Contraseña copiada.';

  @override
  String provisionalPasswordValidUntil(String date) {
    return 'Válida hasta $date';
  }

  @override
  String get userCreatedTitle => 'Usuario registrado';

  @override
  String get userResetPassword => 'Restablecer contraseña';

  @override
  String userResetPasswordMessage(String name) {
    return 'Se generará una nueva contraseña provisional para $name y se cerrarán todas sus sesiones. ¿Deseas continuar?';
  }

  @override
  String get userResetPasswordFallbackName => 'el usuario';

  @override
  String get userResetConfirm => 'Restablecer';

  @override
  String get userPasswordResetTitle => 'Contraseña restablecida';

  @override
  String get userFormEditTitle => 'Editar usuario';

  @override
  String get userFormCreateTitle => 'Registrar usuario';

  @override
  String get userEmail => 'Correo electrónico';

  @override
  String get userEmailInvalid => 'Correo electrónico inválido.';

  @override
  String get usersSearch => 'Buscar usuario (nombre o correo electrónico)';

  @override
  String get usersStatusFilter => 'Situación';

  @override
  String get usersActive => 'Activos';

  @override
  String get usersInactive => 'Inactivos';

  @override
  String get usersEmpty => 'Ningún usuario encontrado.';

  @override
  String get activesFetchError => 'Error al buscar los activos.';

  @override
  String get activeFetchError => 'Error al buscar el activo.';

  @override
  String get activeCreateError => 'Error al registrar el activo.';

  @override
  String get activeUpdateError => 'Error al actualizar el activo.';

  @override
  String get historyFetchError => 'Error al buscar el historial.';

  @override
  String get movementsFetchError => 'Error al buscar los movimientos.';

  @override
  String get movementCreateError => 'Error al registrar el movimiento.';

  @override
  String get writeOffError => 'Error al registrar la baja.';

  @override
  String get loginError => 'Error al iniciar sesión.';

  @override
  String get changePasswordError => 'Error al cambiar la contraseña.';

  @override
  String get logoutError => 'Error al cerrar sesión.';

  @override
  String get sessionExpired => 'Tu sesión expiró. Inicia sesión de nuevo.';

  @override
  String get categoriesFetchError => 'Error al buscar las categorías.';

  @override
  String get subcategoriesFetchError => 'Error al buscar las subcategorías.';

  @override
  String get dashboardSummaryFetchError =>
      'Error al buscar el resumen del panel.';

  @override
  String get dashboardByLocationFetchError =>
      'Error al buscar los activos por localidad.';

  @override
  String get locationsFetchError => 'Error al buscar las localidades.';

  @override
  String get locationCreateError => 'Error al registrar la localidad.';

  @override
  String get locationUpdateError => 'Error al actualizar la localidad.';

  @override
  String get sectionsFetchError => 'Error al buscar los sectores.';

  @override
  String get sectionCreateError => 'Error al registrar el sector.';

  @override
  String get sectionUpdateError => 'Error al actualizar el sector.';

  @override
  String get suppliersFetchError => 'Error al buscar los proveedores.';

  @override
  String get supplierCreateError => 'Error al crear el proveedor.';

  @override
  String get supplierUpdateError => 'Error al actualizar el proveedor.';

  @override
  String get typesFetchError => 'Error al buscar los tipos.';

  @override
  String get typeCreateError => 'Error al registrar el tipo.';

  @override
  String get typeUpdateError => 'Error al actualizar el tipo.';

  @override
  String get usersFetchError => 'Error al buscar los usuarios.';

  @override
  String get userFetchError => 'Error al buscar el usuario.';

  @override
  String get userCreateError => 'Error al registrar el usuario.';

  @override
  String get userUpdateError => 'Error al actualizar el usuario.';

  @override
  String get userResetPasswordError => 'Error al restablecer la contraseña.';

  @override
  String get typeIsKit => 'Es Kit';

  @override
  String get typeIsKitHint =>
      'Los activos de este tipo aceptan ítems asociados, que acompañan los movimientos.';

  @override
  String get typeKitTag => 'Kit';

  @override
  String get kitItemsTitle => 'Ítems del Kit';

  @override
  String get kitItemsEmpty => 'Ningún ítem asociado.';

  @override
  String get kitAddItem => 'Agregar ítem';

  @override
  String get kitAddItemTitle => 'Agregar ítem al Kit';

  @override
  String get kitAddItemSearch => 'Buscar activo';

  @override
  String get kitAddItemEmpty =>
      'Ningún activo disponible en el mismo estado del Kit.';

  @override
  String get kitAddItemSuccess => '¡Ítem agregado al Kit!';

  @override
  String get kitRemoveItem => 'Quitar del Kit';

  @override
  String get kitRemoveItemSuccess => '¡Ítem quitado del Kit!';

  @override
  String get kitRemoveConfirmTitle => 'Quitar ítem del Kit';

  @override
  String kitRemoveConfirmMessage(String code) {
    return 'El activo $code dejará de acompañar los movimientos del Kit. ¿Desea continuar?';
  }

  @override
  String get kitItemDifferentStatus =>
      'Estado diferente del Kit: no acompaña los movimientos.';

  @override
  String kitBelongsTo(String code, String name) {
    return 'Pertenece al Kit $code · $name';
  }

  @override
  String get kitBelongsToHint =>
      'Este ítem acompaña los movimientos del Kit. Para moverlo o darlo de baja solo, quítelo del Kit.';

  @override
  String get kitOpen => 'Abrir Kit';

  @override
  String get kitItemAddError => 'Error al agregar el ítem al Kit.';

  @override
  String get kitItemRemoveError => 'Error al quitar el ítem del Kit.';

  @override
  String moveKitItemsFollow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ítems acompañarán el movimiento.',
      one: '1 ítem acompañará el movimiento.',
      zero: 'Ningún ítem acompañará el movimiento.',
    );
    return '$_temp0';
  }

  @override
  String get moveKitItemsLeftBehind => 'No acompañarán:';

  @override
  String moveSuccessKitLeftBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ítems no acompañaron al Kit.',
      one: '1 ítem no acompañó al Kit.',
    );
    return 'Movimiento registrado. $_temp0';
  }

  @override
  String get activeTabDetails => 'Ficha';

  @override
  String get activeTabFiles => 'Archivos';

  @override
  String get attachmentsEmpty => 'Ningún archivo adjunto.';

  @override
  String get attachmentAdd => 'Agregar archivo';

  @override
  String get attachmentPickFile => 'Elegir archivo';

  @override
  String get attachmentTakePhoto => 'Tomar foto';

  @override
  String get attachmentCategoryTitle => 'Categoría del archivo';

  @override
  String get attachmentCategoryNf => 'Factura';

  @override
  String get attachmentCategoryPhoto => 'Foto';

  @override
  String get attachmentCategoryManual => 'Manual';

  @override
  String get attachmentCategoryCertificate => 'Certificado';

  @override
  String get attachmentCategoryTerm => 'Término';

  @override
  String get attachmentCategoryReport => 'Informe técnico';

  @override
  String get attachmentSend => 'Enviar';

  @override
  String attachmentUploading(int percent) {
    return 'Enviando archivo… $percent%';
  }

  @override
  String get attachmentUploadSuccess => '¡Archivo enviado!';

  @override
  String get attachmentFileName => 'Nombre del archivo';

  @override
  String get attachmentRename => 'Renombrar';

  @override
  String get attachmentRenameSuccess => '¡Archivo renombrado!';

  @override
  String get attachmentRemove => 'Eliminar';

  @override
  String get attachmentRemoveConfirmTitle => 'Eliminar archivo';

  @override
  String attachmentRemoveConfirmMessage(String name) {
    return '¿Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get attachmentRemoveSuccess => '¡Archivo eliminado!';

  @override
  String get attachmentsFetchError =>
      'Error al cargar los archivos del activo.';

  @override
  String get attachmentUploadError => 'Error al enviar el archivo.';

  @override
  String get attachmentDownloadError => 'Error al descargar el archivo.';

  @override
  String get attachmentOpenError =>
      'No fue posible abrir el archivo en este dispositivo.';

  @override
  String get attachmentRenameError => 'Error al renombrar el archivo.';

  @override
  String get attachmentRemoveError => 'Error al eliminar el archivo.';

  @override
  String get attachmentsUnavailable =>
      'Archivos no disponibles: el servidor no tiene almacenamiento configurado.';

  @override
  String get attachmentTooLarge => 'El archivo supera los 20 MB.';
}
