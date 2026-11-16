import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/user/components/provisional_password_dialog.dart';
import 'package:iveco_find/src/modules/home/pages/user/controllers/add_or_edit_user_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_select.dart';
import 'package:iveco_find/src/shared/components/i_switch.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class AddOrEditUserPage extends StatefulWidget {
  final UserModel? user;
  const AddOrEditUserPage({super.key, this.user});

  @override
  State<AddOrEditUserPage> createState() => _AddOrEditUserPageState();
}

class _AddOrEditUserPageState extends State<AddOrEditUserPage> {
  final controller = GetIt.instance.get<AddOrEditUserController>();

  @override
  void initState() {
    controller.fillFields(widget.user);
    super.initState();
  }

  void _leave(bool reload) {
    controller.clearFields();
    context.pop(reload);
  }

  void _save() {
    if (!controller.formKey.currentState!.validate()) return;
    controller.save(
      onCreated: (password) async {
        if (!mounted) return;
        await showProvisionalPasswordDialog(
          context,
          password: password,
          title: AppLocalizations.of(context)!.userCreatedTitle,
        );
        if (!mounted) return;
        _leave(true);
      },
      onUpdated: () {
        if (!mounted) return;
        SnackbarUtil.showSuccess(
          context,
          message: AppLocalizations.of(context)!.commonUpdatedSuccess,
        );
        _leave(true);
      },
      onError: (message) {
        if (!mounted) return;
        SnackbarUtil.showError(context, message: message);
      },
    );
  }

  Future<void> _resetPassword() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.userResetPassword),
        content: Text(
          l.userResetPasswordMessage(
            controller.user?.nome ?? l.userResetPasswordFallbackName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              l.userResetConfirm,
              style: TextStyle(color: ITheme.colors.alizarin),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    controller.resetPassword(
      onSuccess: (password) {
        if (!mounted) return;
        showProvisionalPasswordDialog(
          context,
          password: password,
          title: l.userPasswordResetTitle,
        );
      },
      onError: (message) {
        if (!mounted) return;
        SnackbarUtil.showError(context, message: message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final editing = controller.isEditing;
        final l = AppLocalizations.of(context)!;
        final busy =
            controller.behaviour == Behaviour.loading ||
            controller.resettingPassword;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: busy ? null : () => _leave(false),
              icon: Icon(Icons.arrow_back),
            ),
            title: Text(editing ? l.userFormEditTitle : l.userFormCreateTitle),
          ),
          body: switch (controller.behaviourPage) {
            Behaviour.loading => Center(child: CircularProgressIndicator()),
            Behaviour.error => ErrorPage(onRetry: controller.load),
            Behaviour.success => SingleChildScrollView(
              padding: EdgeInsets.all(md),
              child: Form(
                key: controller.formKey,
                child: Column(
                  spacing: md,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ITextField(
                      label: l.commonName,
                      controller: controller.nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l.commonRequiredField;
                        }
                        return null;
                      },
                    ),
                    ITextField(
                      label: l.userEmail,
                      controller: controller.emailController,
                      enabled: !editing,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (editing) return null;
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return l.commonRequiredField;
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return l.userEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    ISelect<UserProfile>(
                      label: l.commonProfile,
                      value: controller.perfil,
                      items: UserProfile.values,
                      itemLabel: (item) => item.label(l),
                      onChanged: controller.changePerfil,
                      validator: (value) =>
                          value == null ? l.commonRequiredField : null,
                    ),
                    if (editing) ...[
                      ISwitch(
                        value: controller.active,
                        onChanged: controller.changeActive,
                        label: l.commonActive,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: IButton.secondary(
                          text: l.userResetPassword,
                          isLoading: controller.resettingPassword,
                          onTap: _resetPassword,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          },
          bottomNavigationBar: controller.behaviourPage == Behaviour.success
              ? Padding(
                  padding: EdgeInsets.all(md),
                  child: IButton.primary(
                    text: editing ? l.commonSave : l.commonRegister,
                    isLoading: controller.behaviour == Behaviour.loading,
                    onTap: _save,
                  ),
                )
              : null,
        );
      },
    );
  }
}
