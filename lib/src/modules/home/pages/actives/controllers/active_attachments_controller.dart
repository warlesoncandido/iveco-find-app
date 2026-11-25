import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/repositories/attachment_repository.dart';
import 'package:iveco_find/src/shared/services/attachment_cache/attachment_cache.dart';
import 'package:iveco_find/src/shared/services/attachment_compressor.dart';
import 'package:iveco_find/src/shared/services/attachment_opener/attachment_opener.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

/// Arquivo escolhido no seletor ou tirado pela câmera, pronto para envio.
class PickedAttachmentFile {
  final Uint8List bytes;
  final String name;

  /// Já sai reduzido de quem gerou (foto da câmera via `image_picker`): não
  /// passa de novo pelo [AttachmentCompressor].
  final bool compressed;

  PickedAttachmentFile({
    required this.bytes,
    required this.name,
    this.compressed = false,
  });
}

/// Aba "Arquivos" da ficha do Ativo: lista, envia, carrega para o visualizador,
/// renomeia e remove Anexos.
/// Quem decide se o usuário pode alterar é a ficha (`canEdit`: `ativos:escrever` e
/// Ativo não Baixado); a API também recusa (403 / 422 `ATIVO_BAIXADO`).
class ActiveAttachmentsController extends ChangeNotifier {
  final AttachmentRepository repository;
  final AttachmentOpener opener;
  final AttachmentCompressor compressor;
  final AttachmentCache cache;

  ActiveAttachmentsController({
    required this.repository,
    required this.opener,
    required this.compressor,
    required this.cache,
  });

  String? activeId;

  List<AttachmentModel> attachments = [];

  Behaviour behaviour = Behaviour.loading;

  /// Mensagem do erro de carregamento (ex.: API sem armazenamento).
  String? loadError;

  /// Progresso do envio em andamento (0..1); `null` quando nada está sendo enviado.
  double? uploadProgress;

  bool get uploading => uploadProgress != null;

  /// Compactando o arquivo antes do envio (barra indeterminada na aba).
  bool preparing = false;

  /// Preparando ou enviando: não aceita outro envio.
  bool get busy => preparing || uploading;

  /// Anexo sendo carregado para abrir (mostra o indicador na linha).
  String? openingId;

  Future<void> init(String id) async {
    activeId = id;
    attachments = [];
    uploadProgress = null;
    preparing = false;
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
    if (id == null || busy) return;
    if (file.bytes.isEmpty) {
      onError(L10n.current.attachmentUploadError);
      return;
    }
    var bytes = file.bytes;
    if (!file.compressed) {
      preparing = true;
      notifyListeners();
      // Melhor esforço: o compactador devolve o original se falhar ou não reduzir.
      bytes = await compressor.compress(file.bytes, file.name);
      // A ficha mudou de Ativo: `init` já zerou o estado.
      if (id != activeId) return;
      preparing = false;
    }
    // O limite de 20 MB vale para o que vai de fato ser enviado (já compactado).
    if (bytes.length > AttachmentModel.maxBytes) {
      notifyListeners();
      onError(L10n.current.attachmentTooLarge);
      return;
    }
    uploadProgress = 0;
    notifyListeners();
    final result = await repository.upload(
      activeId: id,
      bytes: bytes,
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

  /// Conteúdo do Anexo para o visualizador: do cache local quando o tamanho bate
  /// com `tamanhoBytes`; senão baixa uma vez e guarda no cache. `null` quando o
  /// download falha (já avisado por [onError]) ou outro Anexo está carregando.
  Future<Uint8List?> loadContent(
    AttachmentModel attachment, {
    required Function(String message) onError,
  }) async {
    final id = activeId;
    if (id == null || openingId != null) return null;
    openingId = attachment.id;
    notifyListeners();
    try {
      final cached = await _cacheGet(attachment);
      if (cached != null) return cached;
      final result = await repository.download(
        activeId: id,
        attachmentId: attachment.id,
      );
      return await result.fold(
        (l) async {
          onError(l.message ?? L10n.current.attachmentDownloadError);
          return null;
        },
        (bytes) async {
          // Tamanho divergente nunca seria aceito pelo `get`: não vale gravar.
          if (bytes.length == attachment.tamanhoBytes) {
            await _cachePut(attachment.id, bytes);
          }
          return bytes;
        },
      );
    } finally {
      openingId = null;
      notifyListeners();
    }
  }

  /// "Abrir em outro app": entrega ao [opener] os bytes já carregados (sem baixar).
  Future<void> openExternally(
    AttachmentModel attachment,
    Uint8List bytes, {
    required Function(String message) onError,
  }) async {
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
  }

  // O cache já não lança; o try/catch garante que uma falha nunca impeça abrir.
  Future<Uint8List?> _cacheGet(AttachmentModel a) async {
    try {
      return await cache.get(a.id, a.tamanhoBytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cachePut(String attachmentId, Uint8List bytes) async {
    try {
      await cache.put(attachmentId, bytes);
    } catch (_) {}
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
    // Removido na API: sai do cache mesmo que a ficha tenha mudado de Ativo.
    if (result.isRight()) {
      try {
        await cache.remove(attachment.id);
      } catch (_) {}
    }
    if (id != activeId) return; // a ficha mudou de Ativo
    result.fold((l) => onError(l.message ?? ''), (_) {
      attachments = attachments.where((a) => a.id != attachment.id).toList();
      onSuccess();
    });
    notifyListeners();
  }
}
