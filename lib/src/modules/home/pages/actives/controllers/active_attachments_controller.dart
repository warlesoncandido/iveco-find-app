import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/repositories/attachment_repository.dart';
import 'package:iveco_find/src/shared/services/attachment_opener/attachment_opener.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

/// Arquivo escolhido no seletor ou tirado pela câmera, pronto para envio.
class PickedAttachmentFile {
  final Uint8List bytes;
  final String name;
  PickedAttachmentFile({required this.bytes, required this.name});
}

/// Aba "Arquivos" da ficha do Ativo: lista, envia, abre, renomeia e remove Anexos.
/// Quem decide se o usuário pode alterar é a ficha (`canEdit`: `ativos:escrever` e
/// Ativo não Baixado); a API também recusa (403 / 422 `ATIVO_BAIXADO`).
class ActiveAttachmentsController extends ChangeNotifier {
  final AttachmentRepository repository;
  final AttachmentOpener opener;

  ActiveAttachmentsController({required this.repository, required this.opener});

  String? activeId;

  List<AttachmentModel> attachments = [];

  Behaviour behaviour = Behaviour.loading;

  /// Mensagem do erro de carregamento (ex.: API sem armazenamento).
  String? loadError;

  /// Progresso do envio em andamento (0..1); `null` quando nada está sendo enviado.
  double? uploadProgress;

  bool get uploading => uploadProgress != null;

  /// Anexo sendo baixado para abrir (mostra o indicador na linha).
  String? openingId;

  Future<void> init(String id) async {
    activeId = id;
    attachments = [];
    uploadProgress = null;
    openingId = null;
    await load();
  }

  Future<void> load() async {
    final id = activeId;
    if (id == null) return;
    behaviour = Behaviour.loading;
    loadError = null;
    notifyListeners();
    final result = await repository.getAttachments(id);
    if (id != activeId) return; // a ficha mudou de Ativo no meio do caminho
    result.fold(
      (l) {
        loadError = l.message;
        behaviour = Behaviour.error;
      },
      (r) {
        attachments = r;
        behaviour = Behaviour.success;
      },
    );
    notifyListeners();
  }

  Future<void> upload(
    PickedAttachmentFile file,
    AttachmentCategory category, {
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    final id = activeId;
    if (id == null || uploading) return;
    if (file.bytes.length > AttachmentModel.maxBytes) {
      onError(L10n.current.attachmentTooLarge);
      return;
    }
    if (file.bytes.isEmpty) {
      onError(L10n.current.attachmentUploadError);
      return;
    }
    uploadProgress = 0;
    notifyListeners();
    final result = await repository.upload(
      activeId: id,
      bytes: file.bytes,
      fileName: file.name,
      category: category,
      onProgress: (p) {
        if (id != activeId) return; // a ficha mudou de Ativo
        uploadProgress = p;
        notifyListeners();
      },
    );
    // A ficha mudou de Ativo durante o envio: `init` já zerou o estado.
    if (id != activeId) return;
    uploadProgress = null;
    result.fold((l) => onError(l.message ?? ''), (r) {
      attachments = [r, ...attachments];
      behaviour = Behaviour.success;
      onSuccess();
    });
    notifyListeners();
  }

  Future<void> open(
    AttachmentModel attachment, {
    required Function(String message) onError,
  }) async {
    final id = activeId;
    if (id == null || openingId != null) return;
    openingId = attachment.id;
    notifyListeners();
    final result = await repository.download(
      activeId: id,
      attachmentId: attachment.id,
    );
    try {
      await result.fold((l) async => onError(l.message ?? ''), (bytes) async {
        try {
          await opener.open(
            attachment.id,
            bytes,
            attachment.nome,
            attachment.tipoConteudo,
          );
        } catch (_) {
          onError(L10n.current.attachmentOpenError);
        }
      });
    } finally {
      openingId = null;
      notifyListeners();
    }
  }

  Future<void> rename(
    AttachmentModel attachment,
    String name, {
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    final id = activeId;
    final trimmed = name.trim();
    if (id == null) return;
    if (trimmed.isEmpty) {
      onError(L10n.current.commonRequiredField);
      return;
    }
    final result = await repository.rename(
      activeId: id,
      attachmentId: attachment.id,
      name: trimmed,
    );
    if (id != activeId) return; // a ficha mudou de Ativo
    result.fold((l) => onError(l.message ?? ''), (r) {
      attachments = [for (final a in attachments) a.id == r.id ? r : a];
      onSuccess();
    });
    notifyListeners();
  }

  Future<void> remove(
    AttachmentModel attachment, {
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    final id = activeId;
    if (id == null) return;
    final result = await repository.remove(
      activeId: id,
      attachmentId: attachment.id,
    );
    if (id != activeId) return; // a ficha mudou de Ativo
    result.fold((l) => onError(l.message ?? ''), (_) {
      attachments = attachments.where((a) => a.id != attachment.id).toList();
      onSuccess();
    });
    notifyListeners();
  }
}
