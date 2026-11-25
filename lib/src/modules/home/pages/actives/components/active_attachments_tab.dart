import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_attachments_controller.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/platform_helper.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

/// Aba "Arquivos" da ficha do Ativo. Enviar, renomear e remover só com [canEdit]
/// (`ativos:escrever` e Ativo não Baixado); listar e abrir valem para todos.
class ActiveAttachmentsTab extends StatelessWidget {
  final ActiveAttachmentsController controller;
  final bool canEdit;

  const ActiveAttachmentsTab({
    super.key,
    required this.controller,
    required this.canEdit,
  });

  /// Câmera só no app Android/iOS (na web, o seletor de arquivos basta).
  static bool get cameraAvailable =>
      !PlatformHelper.isWeb && PlatformHelper.isMobile;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        // Scaffold interno só para o FAB ficar fixo sobre a aba "Arquivos".
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton:
              canEdit && controller.behaviour == Behaviour.success
              ? FloatingActionButton.extended(
                  key: const Key('attachment-add'),
                  heroTag: 'attachment-add',
                  backgroundColor: controller.busy
                      ? ITheme.colors.cinza145
                      : ITheme.colors.primary,
                  foregroundColor: ITheme.colors.branco,
                  onPressed: controller.busy ? null : () => _add(context),
                  icon: const Icon(Icons.upload_file),
                  label: Text(l.attachmentAdd),
                )
              : null,
          body: _buildContent(context, l),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l) {
    return switch (controller.behaviour) {
      Behaviour.loading => const Center(child: CircularProgressIndicator()),
      Behaviour.error =>
        controller.loadError != null
            ? _Message(
                text: controller.loadError!,
                action: TextButton(
                  onPressed: controller.load,
                  child: Text(l.commonRetry),
                ),
              )
            : ErrorPage(onRetry: controller.load),
      Behaviour.success => _buildList(context, l),
    };
  }

  Widget _buildList(BuildContext context, AppLocalizations l) {
    final items = controller.attachments;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        // Espaço no fim para o FAB não cobrir o último Anexo.
        padding: EdgeInsets.fromLTRB(md, md, md, md + 72),
        children: [
          if (controller.preparing) ...[
            Text(l.attachmentPreparing, style: ITheme.styles.bodyLight()),
            SizedBox(height: xs),
            const LinearProgressIndicator(key: Key('attachment-preparing')),
          ],
          if (controller.uploading) ...[
            Text(
              l.attachmentUploading(
                ((controller.uploadProgress ?? 0) * 100).round(),
              ),
              style: ITheme.styles.bodyLight(),
            ),
            SizedBox(height: xs),
            LinearProgressIndicator(value: controller.uploadProgress),
          ],
          SizedBox(height: sm),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: md * 2),
              child: Center(
                child: Text(
                  l.attachmentsEmpty,
                  style: ITheme.styles.bodyLight(),
                ),
              ),
            ),
          for (final a in items) _buildItem(context, l, a),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    AppLocalizations l,
    AttachmentModel a,
  ) {
    final date = DateHelper.formatDateTime(a.enviadoEm);
    return Card(
      color: ITheme.colors.branco,
      child: ListTile(
        key: Key('attachment-${a.id}'),
        onTap: () => _open(context, a),
        leading: controller.openingId == a.id
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                a.isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                color: a.isPdf ? ITheme.colors.alizarin : ITheme.colors.primary,
              ),
        title: Text(a.nome, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${a.categoria.label(l)} · ${AttachmentModel.formatSize(a.tamanhoBytes)} · $date',
        ),
        trailing: canEdit
            ? PopupMenuButton<String>(
                key: Key('attachment-menu-${a.id}'),
                onSelected: (value) => value == 'rename'
                    ? _rename(context, a)
                    : _remove(context, a),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l.attachmentRename),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(l.attachmentRemove),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final source = cameraAvailable
        ? await showModalBottomSheet<String>(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: Text(l.attachmentPickFile),
                    onTap: () => Navigator.of(context).pop('file'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(l.attachmentTakePhoto),
                    onTap: () => Navigator.of(context).pop('camera'),
                  ),
                ],
              ),
            ),
          )
        : 'file';
    if (source == null || !context.mounted) return;

    final file = source == 'camera' ? await _takePhoto() : await _pickFile();
    if (file == null || !context.mounted) return;

    final category = await _askCategory(context, file.name);
    if (category == null || !context.mounted) return;

    await controller.upload(
      file,
      category,
      onSuccess: () {
        if (context.mounted) {
          SnackbarUtil.showSuccess(context, message: l.attachmentUploadSuccess);
        }
      },
      onError: (message) {
        if (context.mounted) SnackbarUtil.showError(context, message: message);
      },
    );
  }

  Future<PickedAttachmentFile?> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: AttachmentModel.allowedExtensions,
      withData: true,
    );
    final picked = result?.files.singleOrNull;
    final bytes = picked?.bytes;
    if (picked == null || bytes == null) return null;
    return PickedAttachmentFile(bytes: bytes, name: picked.name);
  }

  /// Foto em JPG (a qualidade < 100 faz o image_picker comprimir em JPEG). Já sai
  /// reduzida: `compressed` evita compactar de novo.
  Future<PickedAttachmentFile?> _takePhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 2560,
      maxHeight: 2560,
    );
    if (photo == null) return null;
    final name =
        'foto_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';
    return PickedAttachmentFile(
      bytes: await photo.readAsBytes(),
      name: name,
      compressed: true,
    );
  }

  Future<AttachmentCategory?> _askCategory(
    BuildContext context,
    String fileName,
  ) {
    final l = AppLocalizations.of(context)!;
    return showDialog<AttachmentCategory>(
      context: context,
      builder: (context) {
        AttachmentCategory? selected;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l.attachmentCategoryTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: ITheme.styles.bodyLight()),
                SizedBox(height: sm),
                RadioGroup<AttachmentCategory>(
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in AttachmentCategory.values)
                        RadioListTile<AttachmentCategory>(
                          contentPadding: EdgeInsets.zero,
                          value: c,
                          title: Text(c.label(l)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.commonCancel),
              ),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () => Navigator.of(context).pop(selected),
                child: Text(l.attachmentSend),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _open(BuildContext context, AttachmentModel a) async {
    await controller.open(
      a,
      onError: (message) {
        if (context.mounted) SnackbarUtil.showError(context, message: message);
      },
    );
  }

  Future<void> _rename(BuildContext context, AttachmentModel a) async {
    final l = AppLocalizations.of(context)!;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(initialName: a.nome),
    );
    if (name == null || name.trim() == a.nome || !context.mounted) return;
    await controller.rename(
      a,
      name,
      onSuccess: () {
        if (context.mounted) {
          SnackbarUtil.showSuccess(context, message: l.attachmentRenameSuccess);
        }
      },
      onError: (message) {
        if (context.mounted) SnackbarUtil.showError(context, message: message);
      },
    );
  }

  Future<void> _remove(BuildContext context, AttachmentModel a) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.attachmentRemoveConfirmTitle),
        content: Text(l.attachmentRemoveConfirmMessage(a.nome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.attachmentRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await controller.remove(
      a,
      onSuccess: () {
        if (context.mounted) {
          SnackbarUtil.showSuccess(context, message: l.attachmentRemoveSuccess);
        }
      },
      onError: (message) {
        if (context.mounted) SnackbarUtil.showError(context, message: message);
      },
    );
  }
}

/// Diálogo de renomear: dono do [TextEditingController], descartado só quando o
/// diálogo sai da árvore (depois da animação de saída).
class _RenameDialog extends StatefulWidget {
  final String initialName;
  const _RenameDialog({required this.initialName});

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _text = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.attachmentRename),
      content: TextField(
        controller: _text,
        autofocus: true,
        maxLength: 255,
        decoration: InputDecoration(labelText: l.attachmentFileName),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(l.commonSave),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final Widget action;
  const _Message({required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: ITheme.styles.bodyLight(),
            ),
            SizedBox(height: sm),
            action,
          ],
        ),
      ),
    );
  }
}
