import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/add_or_edit_active_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_select.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/formatters/date_formatter.dart';
import 'package:iveco_find/src/shared/utils/formatters/money_formatter.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/screen_helper.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class AddOrEditActivePage extends StatefulWidget {
  final ActiveModel? active;
  const AddOrEditActivePage({super.key, this.active});

  @override
  State<AddOrEditActivePage> createState() => _AddOrEditActivePageState();
}

class _AddOrEditActivePageState extends State<AddOrEditActivePage> {
  final controller = GetIt.instance.get<AddOrEditActiveController>();

  @override
  void initState() {
    controller.init(widget.active);
    super.initState();
  }

  AppLocalizations get _l => AppLocalizations.of(context)!;

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l.commonRequiredField;
    }
    return null;
  }

  String? _requiredSelect(RefModel? value) {
    if (value == null) {
      return _l.commonRequiredField;
    }
    return null;
  }

  String? _date(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? _l.commonRequiredField : null;
    }
    if (!DateHelper.isValidBr(value)) {
      return _l.commonInvalidDate;
    }
    return null;
  }

  bool _sameRef(RefModel a, RefModel b) => a.id == b.id;

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
                context.pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text(
              controller.isEditing
                  ? l.activeFormEditTitle
                  : l.activeFormCreateTitle,
            ),
          ),
          body: switch (controller.behaviourPage) {
            Behaviour.loading => Center(child: CircularProgressIndicator()),
            Behaviour.error => ErrorPage(onRetry: controller.loadOptions),
            Behaviour.success => _buildForm(context),
          },
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(md),
            child: IButton.primary(
              isLoading: controller.behaviour == Behaviour.loading,
              isDisabled: controller.behaviourPage != Behaviour.success,
              text: controller.isEditing ? l.commonSave : l.commonRegister,
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.saveActive(
                    onSuccess: (active) {
                      SnackbarUtil.showSuccess(
                        context,
                        message: controller.isEditing
                            ? l.commonUpdatedSuccess
                            : l.activeFormCreatedSuccess(active.codigoInterno),
                      );
                      controller.clearFields();
                      context.pop(active.id);
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

  Widget _buildForm(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxWidth - md * 2;
        final half = ScreenHelper.isMobile(context) ? full : (full - md) / 2;

        Widget field(Widget child, {bool isFull = false}) =>
            SizedBox(width: isFull ? full : half, child: child);

        return SingleChildScrollView(
          padding: EdgeInsets.all(md),
          child: Form(
            key: controller.formKey,
            child: Wrap(
              spacing: md,
              runSpacing: md,
              children: [
                if (controller.isEditing)
                  field(
                    ITextField(
                      label: l.fieldInternalCode,
                      enabled: false,
                      controller: TextEditingController(
                        text: controller.active!.codigoInterno,
                      ),
                    ),
                    isFull: true,
                  ),
                field(
                  ITextField(
                    label: l.activeFormName,
                    controller: controller.nameController,
                    validator: _required,
                  ),
                  isFull: true,
                ),
                field(
                  ISelect<RefModel>(
                    label: l.activeFormType,
                    items: controller.types,
                    value: controller.type,
                    compare: _sameRef,
                    itemLabel: (e) => e.nome,
                    onChanged: controller.changeType,
                    validator: _requiredSelect,
                  ),
                ),
                field(
                  ISelect<RefModel>(
                    label: l.fieldSupplier,
                    items: controller.suppliers,
                    value: controller.supplier,
                    compare: _sameRef,
                    itemLabel: (e) => e.nome,
                    onChanged: controller.changeSupplier,
                  ),
                ),
                if (controller.isEditing)
                  field(
                    ITextField(
                      label: l.activeFormLocationReadOnly,
                      enabled: false,
                      controller: TextEditingController(
                        text:
                            '${controller.active!.setor.nome} (${controller.active!.localidade.nome})',
                      ),
                    ),
                    isFull: true,
                  )
                else ...[
                  field(
                    ISelect<RefModel>(
                      label: l.activeFormLocality,
                      items: controller.locations,
                      value: controller.location,
                      compare: _sameRef,
                      itemLabel: (e) => e.nome,
                      onChanged: controller.changeLocation,
                      validator: _requiredSelect,
                    ),
                  ),
                  field(
                    ISelect<RefModel>(
                      label: l.activeFormSection,
                      items: controller.sections,
                      value: controller.section,
                      compare: _sameRef,
                      itemLabel: (e) => e.nome,
                      onChanged: controller.changeSection,
                      validator: _requiredSelect,
                      enabled: controller.location != null,
                    ),
                  ),
                ],
                field(
                  ITextField(
                    label: l.fieldSapCode,
                    controller: controller.sapCodeController,
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldSerialNumber,
                    controller: controller.serialNumberController,
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldPatrimony,
                    controller: controller.patrimonyController,
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldResponsible,
                    controller: controller.responsibleController,
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldBrand,
                    controller: controller.brandController,
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldModel,
                    controller: controller.modelController,
                  ),
                ),
                field(
                  ITextField(
                    label: l.activeFormEntryDate,
                    controller: controller.entryDateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateInputFormatter()],
                    validator: (value) => _date(value, required: true),
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldAcquisitionDate,
                    controller: controller.acquisitionDateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateInputFormatter()],
                    validator: _date,
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldValue,
                    controller: controller.valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [MoneyInputFormatter()],
                  ),
                ),
                field(
                  ITextField(
                    label: l.fieldUsefulLifeMonths,
                    controller: controller.usefulLifeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          int.parse(value) < 1) {
                        return l.activeFormUsefulLifeMin;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
