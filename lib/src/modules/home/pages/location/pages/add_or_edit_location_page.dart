import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/location/controllers/add_or_edit_location_controller.dart';
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
        final l = AppLocalizations.of(context)!;
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
                  ? l.locationFormEditTitle
                  : l.locationFormCreateTitle,
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
                    label: l.commonName,
                    controller: controller.nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return l.commonRequiredField;
                      }
                      return null;
                    },
                  ),
                  if (controller.location != null)
                    ISwitch(
                      value: controller.active,
                      onChanged: controller.changeActive,
                      label: l.commonActive,
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(md),
            child: IButton.primary(
              isLoading: controller.behaviour == Behaviour.loading,
              text: controller.location != null
                  ? l.commonEdit
                  : l.commonRegister,
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.saveLocation(
                    onSuccess: () {
                      SnackbarUtil.showSuccess(
                        context,
                        message: controller.location != null
                            ? l.commonUpdatedSuccess
                            : l.commonCreatedSuccess,
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
