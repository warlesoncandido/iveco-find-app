import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/models/provisional_password_model.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';

/// Mostra a Senha Provisória (só vem nesta resposta da API).
/// Não fecha com toque fora para o Administrador não perder a senha.
Future<void> showProvisionalPasswordDialog(
  BuildContext context, {
  required ProvisionalPasswordModel password,
  String? title,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProvisionalPasswordDialog(
      password: password,
      title: title ?? AppLocalizations.of(context)!.provisionalPasswordTitle,
    ),
  );
}

class ProvisionalPasswordDialog extends StatelessWidget {
  final ProvisionalPasswordModel password;
  final String title;
  const ProvisionalPasswordDialog({
    super.key,
    required this.password,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: md,
        children: [
          Text(l.provisionalPasswordHint),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  password.senhaProvisoria,
                  style: ITheme.styles.bodyBold(),
                ),
              ),
              IconButton(
                tooltip: l.provisionalPasswordCopy,
                icon: Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: password.senhaProvisoria),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.provisionalPasswordCopied)),
                    );
                  }
                },
              ),
            ],
          ),
          Text(
            l.provisionalPasswordValidUntil(
              DateHelper.formatDateTime(password.senhaProvisoriaExpiraEm),
            ),
            style: ITheme.styles.bodyLight(color: ITheme.colors.cinza145),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: Text(l.commonClose)),
      ],
    );
  }
}
