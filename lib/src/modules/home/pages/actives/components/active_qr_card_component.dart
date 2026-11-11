import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/services/active_label_printer.dart';
import 'package:iveco_find/src/shared/utils/helpers/public_url_helper.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Card com o QR Code do Ativo (`{PUBLIC_URL}/a/{id}`), o código interno e a
/// impressão da etiqueta.
class ActiveQrCardComponent extends StatefulWidget {
  final String id;
  final String codigoInterno;
  final String nome;
  final ActiveLabelPrinter printer;

  /// URL gravada no QR; por padrão `PublicUrl.ativo(id)`.
  final String url;

  ActiveQrCardComponent({
    super.key,
    required this.id,
    required this.codigoInterno,
    required this.nome,
    this.printer = const ActiveLabelPrinter(),
    String? url,
  }) : url = url ?? PublicUrl.ativo(id);

  @override
  State<ActiveQrCardComponent> createState() => _ActiveQrCardComponentState();
}

class _ActiveQrCardComponentState extends State<ActiveQrCardComponent> {
  bool _printing = false;

  Future<void> _print() async {
    setState(() => _printing = true);
    try {
      await widget.printer.printLabel(
        url: widget.url,
        codigoInterno: widget.codigoInterno,
        nome: widget.nome,
      );
    } catch (_) {
      if (mounted) {
        SnackbarUtil.showError(
          context,
          message: 'Não foi possível imprimir a etiqueta.',
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ITheme.colors.branco,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QR Code', style: ITheme.styles.subTitleBold()),
            SizedBox(height: sm),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: widget.url,
                    size: 180,
                    backgroundColor: Colors.white,
                    semanticsLabel: 'QR Code do Ativo ${widget.codigoInterno}',
                  ),
                  SizedBox(height: xs),
                  Text(widget.codigoInterno, style: ITheme.styles.bodyBold()),
                  SizedBox(height: sm),
                  OutlinedButton.icon(
                    onPressed: _printing ? null : _print,
                    icon: _printing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.print),
                    label: Text('Imprimir etiqueta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
