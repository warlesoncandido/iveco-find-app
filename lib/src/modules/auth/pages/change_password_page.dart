import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/images.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/auth/controllers/change_password_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_text_button.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final controller = GetIt.instance.get<ChangePasswordController>();

  void _save() {
    if (!controller.formKey.currentState!.validate()) return;
    controller.changePassword(
      onSuccess: () {
        if (!mounted) return;
        SnackbarUtil.showSuccess(context, message: 'Senha alterada com sucesso!');
        context.pushReplacementNamed('/home');
      },
      onError: (message) {
        if (!mounted) return;
        SnackbarUtil.showError(context, message: message);
      },
    );
  }

  void _logout() {
    controller.logout(
      onSuccess: () {
        if (!mounted) return;
        context.goNamed('/');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  return Form(
                    key: controller.formKey,
                    child: Column(
                      spacing: md,
                      children: [
                        Image.asset(IvecoImages.logo, width: 200),
                        Text('Trocar senha', style: ITheme.styles.bodyBold()),
                        Text(
                          'Você entrou com uma senha provisória. Defina uma nova senha para continuar.',
                          textAlign: TextAlign.center,
                          style: ITheme.styles.bodyLight(
                            color: ITheme.colors.cinza145,
                          ),
                        ),
                        ITextField(
                          label: 'Senha atual (provisória)',
                          controller: controller.currentPasswordController,
                          obscureText: true,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),
                        ITextField(
                          label: 'Nova senha',
                          controller: controller.newPasswordController,
                          obscureText: true,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            if (value.length < 8 || value.length > 128) {
                              return 'A senha deve ter de 8 a 128 caracteres';
                            }
                            if (value ==
                                controller.currentPasswordController.text) {
                              return 'A nova senha deve ser diferente da atual';
                            }
                            return null;
                          },
                        ),
                        ITextField(
                          label: 'Confirmar nova senha',
                          controller: controller.confirmPasswordController,
                          obscureText: true,
                          maxLines: 1,
                          validator: (value) {
                            if (value != controller.newPasswordController.text) {
                              return 'As senhas não conferem';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: IButton.primary(
                            text: 'Salvar nova senha',
                            isLoading: controller.isLoading,
                            onTap: _save,
                          ),
                        ),
                        ITextButton(label: 'Sair', onPressed: _logout),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
