import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/controllers/add_or_edit_location_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_switch.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/models/location_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class AddOrEditLocationPage extends StatefulWidget {
  final LocationModel? location;
  const AddOrEditLocationPage({super.key, this.location});

  @override
  State<AddOrEditLocationPage> createState() => _AddOrEditLocationPageState();
}

class _AddOrEditLocationPageState extends State<AddOrEditLocationPage> {
  final controller = GetIt.instance.get<AddOrEditLocationController>();

  @override
  void initState() {
    controller.fillFields(widget.location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
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
              controller.location != null
                  ? 'Editar Localidade'
                  : 'Cadastrar Localidade',
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(md),
            child: Form(
              key: controller.formKey,
              child: Column(
                spacing: md,
                children: [
                  ITextField(
                    label: 'Nome',
                    controller: controller.nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo obrigatorio.';
                      }
                      return null;
                    },
                  ),
                  if (controller.location != null)
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
              isLoading: controller.behaviour == Behaviour.loading,
              text: controller.location != null ? 'Editar' : 'Cadastrar',
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.saveLocation(
                    onSuccess: () {
                      SnackbarUtil.showSuccess(
                        context,
                        message: controller.location != null
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
