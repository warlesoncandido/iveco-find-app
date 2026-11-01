import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/location/controllers/add_or_edit_section_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_switch.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/models/section_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class AddOrEditSectionPage extends StatefulWidget {
  final String locationId;
  final SectionModel? section;
  const AddOrEditSectionPage({
    super.key,
    required this.locationId,
    this.section,
  });

  @override
  State<AddOrEditSectionPage> createState() => _AddOrEditSectionPageState();
}

class _AddOrEditSectionPageState extends State<AddOrEditSectionPage> {
  final controller = GetIt.instance.get<AddOrEditSectionController>();

  @override
  void initState() {
    controller.fillFields(widget.locationId, widget.section);
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
              controller.section != null ? 'Editar Setor' : 'Cadastrar Setor',
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
                  if (controller.section != null)
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
              text: controller.section != null ? 'Editar' : 'Cadastrar',
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.saveSection(
                    onSuccess: () {
                      SnackbarUtil.showSuccess(
                        context,
                        message: controller.section != null
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
