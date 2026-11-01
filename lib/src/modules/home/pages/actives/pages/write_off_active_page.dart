import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/write_off_active_controller.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';

class WriteOffActivePage extends StatefulWidget {
  final ActiveModel active;
  const WriteOffActivePage({super.key, required this.active});

  @override
  State<WriteOffActivePage> createState() => _WriteOffActivePageState();
}

class _WriteOffActivePageState extends State<WriteOffActivePage> {
  final controller = GetIt.instance.get<WriteOffActiveController>();

  @override
  void initState() {
    controller.init(widget.active);
    super.initState();
  }

  Future<void> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar baixa'),
        content: Text(
          'A baixa é definitiva: o ativo ${widget.active.codigoInterno} não poderá mais ser movimentado nem alterado. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Baixar',
              style: TextStyle(color: ITheme.colors.alizarin),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    controller.save(
      onSuccess: () {
        SnackbarUtil.showSuccess(context, message: 'Baixa registrada!');
        context.pop(true);
      },
      onError: (message) {
        SnackbarUtil.showError(context, message: message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        return Scaffold(
          appBar: AppBar(title: Text('Baixar Ativo')),
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
                  ITextField(
                    label: 'Motivo da baixa *',
                    controller: controller.observationController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obrigatorio.';
                      }
                      return null;
                    },
                  ),
                  ITextField(
                    label: 'Responsável',
                    controller: controller.responsibleController,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(md),
            child: IButton.primary(
              isLoading: controller.behaviour == Behaviour.loading,
              text: 'Registrar baixa',
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  _confirm();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
