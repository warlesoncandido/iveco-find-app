import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/move_active_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_select.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class MoveActivePage extends StatefulWidget {
  final ActiveModel active;
  final List<ValidMovementModel> movements;
  const MoveActivePage({
    super.key,
    required this.active,
    required this.movements,
  });

  @override
  State<MoveActivePage> createState() => _MoveActivePageState();
}

class _MoveActivePageState extends State<MoveActivePage> {
  final controller = GetIt.instance.get<MoveActiveController>();

  @override
  void initState() {
    controller.init(widget.active, widget.movements);
    super.initState();
  }

  bool _sameRef(RefModel a, RefModel b) => a.id == b.id;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        final movement = controller.movement;
        return Scaffold(
          appBar: AppBar(title: Text('Movimentar Ativo')),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(md),
            child: Form(
              key: controller.formKey,
              child: Column(
                spacing: md,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.active.codigoInterno} · ${widget.active.nome}',
                    style: ITheme.styles.bodyBold(),
                  ),
                  Text(
                    'Atual: ${widget.active.setor.nome} (${widget.active.localidade.nome})',
                    style: ITheme.styles.bodySmallRegular(
                      color: ITheme.colors.cinza90,
                    ),
                  ),
                  ISelect<ValidMovementModel>(
                    label: 'Movimentação *',
                    items: controller.movements,
                    value: movement,
                    itemLabel: (e) => e.tipo.label,
                    onChanged: controller.changeMovement,
                    validator: (value) =>
                        value == null ? 'Campo obrigatorio.' : null,
                  ),
                  if (movement != null)
                    Row(
                      children: [
                        Text(
                          'Status após a movimentação: ',
                          style: ITheme.styles.bodySmallRegular(),
                        ),
                        ActiveStatusTag(status: movement.statusDestino),
                      ],
                    ),
                  if (controller.showSection) ...[
                    ISelect<RefModel>(
                      label: 'Localidade de destino',
                      items: controller.locations,
                      value: controller.location,
                      compare: _sameRef,
                      itemLabel: (e) => e.nome,
                      onChanged: controller.changeLocation,
                    ),
                    ISelect<RefModel>(
                      label: controller.sectionRequired
                          ? 'Setor de destino *'
                          : 'Setor de destino (opcional)',
                      items: controller.sections,
                      value: controller.section,
                      compare: _sameRef,
                      itemLabel: (e) => e.nome,
                      onChanged: controller.changeSection,
                      validator: controller.validateSection,
                      enabled: controller.location != null,
                    ),
                  ],
                  ITextField(
                    label: 'Responsável',
                    controller: controller.responsibleController,
                  ),
                  ITextField(
                    label: movement?.exigeObservacao == true
                        ? 'Observação *'
                        : 'Observação',
                    controller: controller.observationController,
                    maxLines: 3,
                    validator: (value) {
                      if (movement?.exigeObservacao == true &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Campo obrigatorio.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(md),
            child: IButton.primary(
              isLoading: controller.behaviour == Behaviour.loading,
              text: 'Registrar movimentação',
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.save(
                    onSuccess: () {
                      SnackbarUtil.showSuccess(
                        context,
                        message: 'Movimentação registrada com sucesso!',
                      );
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
