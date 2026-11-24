import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

/// Anexos do Ativo (`/api/v1/ativos/{id}/anexos`).
class AttachmentRepository {
  final ClientDio dio;
  AttachmentRepository({required this.dio});

  /// Ativo Baixado: somente leitura.
  static const activeWrittenOff = 'ATIVO_BAIXADO';

  /// API sem armazenamento configurado (sem `S3_BUCKET`).
  static const notAvailable = 'NAO_IMPLEMENTADO';

  String _base(String activeId) => '/api/v1/ativos/$activeId/anexos';

  Future<Either<Failure, List<AttachmentModel>>> getAttachments(
    String activeId,
  ) async {
    try {
      final result = await dio.get(_base(activeId), isAuth: true);
      return Right(
        (result.data as List)
            .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Left(_failure(e, L10n.current.attachmentsFetchError));
    }
  }

  /// Envia o arquivo (`multipart`: `arquivo` + `categoria`). [onProgress] recebe 0..1.
  Future<Either<Failure, AttachmentModel>> upload({
    required String activeId,
    required Uint8List bytes,
    required String fileName,
    required AttachmentCategory category,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final data = FormData.fromMap({
        'categoria': category.value,
        'arquivo': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final result = await dio.postMultipart(
        _base(activeId),
        data: data,
        isAuth: true,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) onProgress(sent / total);
        },
      );
      return Right(
        AttachmentModel.fromJson(result.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Left(_failure(e, L10n.current.attachmentUploadError));
    }
  }

  Future<Either<Failure, Uint8List>> download({
    required String activeId,
    required String attachmentId,
  }) async {
    try {
      final result = await dio.getBytes(
        '${_base(activeId)}/$attachmentId/conteudo',
        isAuth: true,
      );
      final data = result.data ?? const <int>[];
      return Right(data is Uint8List ? data : Uint8List.fromList(data));
    } catch (e) {
      return Left(_failure(e, L10n.current.attachmentDownloadError));
    }
  }

  Future<Either<Failure, AttachmentModel>> rename({
    required String activeId,
    required String attachmentId,
    required String name,
  }) async {
    try {
      final result = await dio.patch(
        '${_base(activeId)}/$attachmentId',
        isAuth: true,
        data: {'nome': name.trim()},
      );
      return Right(
        AttachmentModel.fromJson(result.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Left(_failure(e, L10n.current.attachmentRenameError));
    }
  }

  Future<Either<Failure, bool>> remove({
    required String activeId,
    required String attachmentId,
  }) async {
    try {
      await dio.delete('${_base(activeId)}/$attachmentId', isAuth: true);
      return const Right(true);
    } catch (e) {
      return Left(_failure(e, L10n.current.attachmentRemoveError));
    }
  }

  /// Lê o Problem Details da API: `detail` e, se houver, a mensagem do primeiro campo.
  Failure _failure(Object error, String fallback) {
    if (error is DioException && error.response?.data is Map) {
      final data = error.response!.data as Map;
      final codigo = data['codigo'] as String?;
      if (codigo == notAvailable) {
        return Failure(
          message: L10n.current.attachmentsUnavailable,
          code: codigo,
        );
      }
      final campos = data['campos'] as List?;
      String? message = data['detail'] as String?;
      if (campos != null && campos.isNotEmpty) {
        message = '${campos.first['campo']}: ${campos.first['mensagem']}';
      }
      return Failure(message: message ?? fallback, code: codigo);
    }
    return Failure(message: fallback);
  }
}
