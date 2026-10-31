import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/controllers/add_or_edit_supplier_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_switch.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/models/supplier_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/formatters/cnpj_formatter.dart';
import 'package:iveco_find/src/shared/utils/formatters/phone_formatter.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class AddOrEditSupplierPage extends StatefulWidget {
  final SupplierModel? supplier;
  const AddOrEditSupplierPage({super.key, this.supplier});

  @override
  State<AddOrEditSupplierPage> createState() => _AddOrEditSupplierPageState();
}

class _AddOrEditSupplierPageState extends State<AddOrEditSupplierPage> {
  final controller = GetIt.instance.get<AddOrEditSupplierController>();

  @override
  void initState() {
    controller.fillFields(widget.supplier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                controller.clearFields();
                context.pop(false);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text(
              controller.supplier != null
                  ? 'Editar Fornecedor'
                  : 'Cadastrar Fornecedor',
            ),
          ),
          body: Padding(
            padding: EdgeInsetsGeometry.all(md),
            child: Form(
              key: controller.formKey,
              child: Column(
                spacing: md,
                children: [
                  ITextField(
                    label: 'Nome do Fornecedor',
                    controller: controller.nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo obrigatório.';
                      }
                      return null;
                    },
                  ),
                  ITextField(
                    label: 'CNPJ do Fornecedor',
                    controller: controller.cnpjController,
                    inputFormatters: [CnpjInputFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obrigatório.';
                      }

                      final cnpj = value.replaceAll(RegExp(r'\D'), '');

                      if (cnpj.length != 14) {
                        return 'CNPJ inválido.';
                      }

                      if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) {
                        return 'CNPJ inválido.';
                      }

                      List<int> multiplicadores1 = [
                        5,
                        4,
                        3,
                        2,
                        9,
                        8,
                        7,
                        6,
                        5,
                        4,
                        3,
                        2,
                      ];
                      int soma = 0;
                      for (int i = 0; i < 12; i++) {
                        soma += int.parse(cnpj[i]) * multiplicadores1[i];
                      }
                      int resto = soma % 11;
                      int digito1 = resto < 2 ? 0 : 11 - resto;

                      if (int.parse(cnpj[12]) != digito1) {
                        return 'CNPJ inválido.';
                      }

                      List<int> multiplicadores2 = [
                        6,
                        5,
                        4,
                        3,
                        2,
                        9,
                        8,
                        7,
                        6,
                        5,
                        4,
                        3,
                        2,
                      ];
                      soma = 0;
                      for (int i = 0; i < 13; i++) {
                        soma += int.parse(cnpj[i]) * multiplicadores2[i];
                      }
                      resto = soma % 11;
                      int digito2 = resto < 2 ? 0 : 11 - resto;

                      if (int.parse(cnpj[13]) != digito2) {
                        return 'CNPJ inválido.';
                      }

                      return null;
                    },
                  ),
                  ITextField(
                    label: 'Telefone do Fornecedor',
                    controller: controller.phoneController,
                    inputFormatters: [PhoneInputFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obrigatório.';
                      }

                      final cleanPhone = value.replaceAll(RegExp(r'\D'), '');

                      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
                        return 'Informe um telefone válido com DDD (10 ou 11 dígitos).';
                      }

                      return null;
                    },
                  ),
                  if (controller.supplier != null)
                    ISwitch(
                      value: controller.active,
                      onChanged: controller.changeActive,
                      label: 'Ativo',
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(md),
            child: IButton.primary(
              text: 'Cadastrar',
              isLoading: controller.behaviour == Behaviour.loading,
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.saveSupplier(
                    onSuccess: () {
                      SnackbarUtil.showSuccess(
                        context,
                        message: controller.supplier != null
                            ? 'Atualizado com sucesso!'
                            : 'Cadastro realizado com sucesso!',
                      );
                      controller.clearFields();
                      context.pop(true);
                    },
                    onError: (message) {
                      SnackbarUtil.showError(context, message: message);
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
