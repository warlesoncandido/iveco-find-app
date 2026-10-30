import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorPage({
    super.key,
    this.message = 'Ocorreu um erro ao carregar as informações.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: ITheme.colors.alizarin,
              ),
              SizedBox(height: md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: ITheme.styles.bodyRegular(color: ITheme.colors.cinza60),
              ),

              SizedBox(height: md),
              IButton.primary(text: 'Tentar novamente', onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
