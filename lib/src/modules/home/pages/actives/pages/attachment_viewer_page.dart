import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_attachments_controller.dart';
import 'package:iveco_find/src/shared/models/attachment_model.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';
import 'package:printing/printing.dart';

/// Visualizador de Anexo dentro do app: imagem em tela cheia com zoom, PDF página
/// a página com zoom. Recebe os bytes já carregados (cache ou download) e os reusa
/// em "Abrir em outro app".
class AttachmentViewerPage extends StatefulWidget {
  final AttachmentModel attachment;
  final Uint8List bytes;

  /// Padrão: o controller registrado no GetIt (testes passam o próprio).
  final ActiveAttachmentsController? controller;

  /// Renderiza o PDF em PNGs, uma página por evento. Padrão:
  /// [defaultPdfRenderer] (testes injetam um `StreamController`).
  final PdfPageRenderer pdfRenderer;

  const AttachmentViewerPage({
    super.key,
    required this.attachment,
    required this.bytes,
    this.controller,
    this.pdfRenderer = defaultPdfRenderer,
  });

  /// `Printing.raster` com cada página convertida em PNG à medida que chega;
  /// `asyncMap` pausa o raster durante a conversão: no máximo uma página crua
  /// na memória por vez.
  static Stream<Uint8List> defaultPdfRenderer(Uint8List bytes, double dpi) =>
      Printing.raster(bytes, dpi: dpi).asyncMap((raster) => raster.toPng());

  @override
  State<AttachmentViewerPage> createState() => _AttachmentViewerPageState();
}

typedef PdfPageRenderer =
    Stream<Uint8List> Function(Uint8List bytes, double dpi);

class _AttachmentViewerPageState extends State<AttachmentViewerPage> {
  late final controller =
      widget.controller ?? GetIt.instance.get<ActiveAttachmentsController>();

  static const _maxScale = 5.0;

  /// Fundo escuro do visualizador.
  static const _background = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final a = widget.attachment;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(a.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            key: const Key('attachment-open-external'),
            tooltip: l.attachmentOpenExternal,
            icon: const Icon(Icons.open_in_new),
            onPressed: _openExternally,
          ),
        ],
      ),
      body: a.isPdf
          ? _PdfView(
              bytes: widget.bytes,
              renderer: widget.pdfRenderer,
              maxScale: _maxScale,
              onOpenExternally: _openExternally,
            )
          : _buildImage(l),
    );
  }

  Widget _buildImage(AppLocalizations l) {
    return InteractiveViewer(
      key: const Key('attachment-viewer-image'),
      minScale: 1,
      maxScale: _maxScale,
      child: Center(
        child: Image.memory(
          widget.bytes,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => _ErrorMessage(
            text: l.attachmentOpenError,
            action: _OpenExternalButton(onPressed: _openExternally),
          ),
        ),
      ),
    );
  }

  Future<void> _openExternally() => controller.openExternally(
    widget.attachment,
    widget.bytes,
    onError: (message) {
      if (mounted) SnackbarUtil.showError(context, message: message);
    },
  );
}

/// PDF renderizado com `Printing.raster`: cada página vira PNG assim que chega
/// (não guarda os pixels crus de todas) e entra na lista, então a primeira
/// aparece sem esperar as demais.
class _PdfView extends StatefulWidget {
  final Uint8List bytes;
  final double maxScale;
  final VoidCallback onOpenExternally;
  final PdfPageRenderer renderer;

  const _PdfView({
    required this.renderer,
    required this.bytes,
    required this.maxScale,
    required this.onOpenExternally,
  });

  @override
  State<_PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<_PdfView> {
  final _pages = <Uint8List>[];
  final _transform = TransformationController();
  StreamSubscription<Uint8List>? _subscription;
  bool _done = false;
  bool _error = false;
  bool _zoomed = false;

  /// Largura de referência da página (A4: 8,27 pol) para calcular o dpi.
  static const _pageWidthInches = 8.27;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subscription == null && !_done) _start();
  }

  /// dpi para a página ter a resolução física da tela (no mínimo 2× a largura
  /// lógica), entre 72 e 200 dpi.
  double _dpi() {
    final width = MediaQuery.sizeOf(context).width;
    final ratio = max(MediaQuery.devicePixelRatioOf(context), 2.0);
    return (width * ratio / _pageWidthInches).clamp(72, 200).toDouble();
  }

  void _start() {
    _subscription = widget
        .renderer(widget.bytes, _dpi())
        .listen(
          (png) {
            if (mounted) setState(() => _pages.add(png));
          },
          onError: (Object _) {
            if (mounted) {
              setState(() {
                _error = true;
                _done = true;
              });
            }
          },
          onDone: () {
            if (mounted) setState(() => _done = true);
          },
          cancelOnError: true,
        );
  }

  void _onTransform() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _transform
      ..removeListener(_onTransform)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_pages.isEmpty) {
      if (_error || _done) {
        return _ErrorMessage(
          text: l.attachmentOpenError,
          action: _OpenExternalButton(onPressed: widget.onOpenExternally),
        );
      }
      return _Rendering(text: l.attachmentRendering);
    }
    final list = InteractiveViewer(
      key: const Key('attachment-viewer-pdf'),
      transformationController: _transform,
      minScale: 1,
      maxScale: widget.maxScale,
      // Sem zoom o arraste rola a lista; com zoom move a página ampliada.
      panEnabled: _zoomed,
      child: ListView.builder(
        padding: EdgeInsets.all(sm),
        itemCount: _pages.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: EdgeInsets.only(bottom: sm),
            child: Image.memory(
              _pages[i],
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            ),
          );
        },
      ),
    );
    // Status fixo sobre a lista: visível mesmo com a 1ª página ocupando a tela.
    final status = _error
        ? _StatusChip(text: l.attachmentOpenError, error: true)
        : !_done
        ? _StatusChip(text: l.attachmentRendering)
        : null;
    if (status == null) return list;
    return Stack(
      children: [
        Positioned.fill(child: list),
        Positioned(
          left: md,
          right: md,
          bottom: md,
          child: SafeArea(child: Center(child: status)),
        ),
      ],
    );
  }
}

/// "Abrir em outro app" mostrado junto do erro (imagem ou PDF que não abre).
class _OpenExternalButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _OpenExternalButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const Key('attachment-error-open-external'),
      onPressed: onPressed,
      icon: const Icon(Icons.open_in_new),
      label: Text(AppLocalizations.of(context)!.attachmentOpenExternal),
    );
  }
}

/// Chip fixo no rodapé do PDF: páginas ainda chegando ou erro no meio.
class _StatusChip extends StatelessWidget {
  final String text;
  final bool error;
  const _StatusChip({required this.text, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      shape: const StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: md, vertical: sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error)
              const Icon(Icons.error_outline, color: Colors.white70, size: 18)
            else
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            SizedBox(width: sm),
            Flexible(
              child: Text(text, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rendering extends StatelessWidget {
  final String text;
  const _Rendering({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: sm),
            Text(text, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String text;
  final Widget? action;
  const _ErrorMessage({required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 40),
            SizedBox(height: sm),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            if (action != null) ...[SizedBox(height: md), action!],
          ],
        ),
      ),
    );
  }
}
