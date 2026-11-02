import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/images.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/auth/controllers/auth_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_text_button.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/utils/helpers/platform_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/screen_helper.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final controller = GetIt.instance.get<AuthController>();

  void _verifyIsLogged() async {
    final isLogged = await controller.isAuthenticated();

    if (isLogged) {
      final mustChange = await controller.mustChangePassword();
      if (!mounted) return;
      context.pushNamed(mustChange ? 'change-password' : '/home');
    }
  }

  @override
  void initState() {
    _verifyIsLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            if (!ScreenHelper.isMobile(context))
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(IvecoImages.login),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
            Expanded(
              flex: 1,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: ITheme.colors.background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(md),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(IvecoImages.logo, width: 200),
                          ITextField(
                            label: 'Email',
                            controller: controller.emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: md),
                          ITextField(
                            label: 'Senha',
                            controller: controller.passwordController,
                            obscureText: true,
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              if (value.length < 6) {
                                return 'Senha deve ter no mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: md),

                          IButton.primary(
                            text: 'Entrar',
                            onTap: () {
                              if (controller.formKey.currentState!.validate()) {
                                controller.auth(
                                  onError: () {
                                    SnackbarUtil.showError(
                                      context,
                                      message: 'Falha ao realizar o login',
                                    );
                                  },
                                  onSuccess: (mustChangePassword) {
                                    if (mustChangePassword) {
                                      context.pushNamed('change-password');
                                      return;
                                    }
                                    context.pushNamed('/home');
                                    SnackbarUtil.showSuccess(
                                      context,
                                      message: 'Login realizado com sucesso!',
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          ITextButton(
                            label: 'Esqueci minha senha',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
