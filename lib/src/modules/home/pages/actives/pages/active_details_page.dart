import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_history_item.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_qr_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_details_controller.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/money_helper.dart';

class ActiveDetailsPage extends StatefulWidget {
  final String id;
  const ActiveDetailsPage({super.key, required this.id});

  @override
  State<ActiveDetailsPage> createState() => _ActiveDetailsPageState();
}

class _ActiveDetailsPageState extends State<ActiveDetailsPage> {
  final controller = GetIt.instance.get<ActiveDetailsController>();

  @override
  void initState() {
    controller.init(widget.id);
    super.initState();
  }

  Future<void> _openAndReload(String name, Object extra) async {
    final result = await context.pushNamed(name, extra: extra);
    if (result != null) {
      controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, value) {
        final active = controller.active;
        final l = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.activeDetailsTitle),
            actions: [
              if (controller.behaviourPage == Behaviour.success &&
                  controller.canEdit)
                IconButton(
                  tooltip: l.commonEdit,
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      _openAndReload('add-or-edit-active', active!),
                ),
            ],
          ),
          body: switch (controller.behaviourPage) {
            Behaviour.loading => Center(child: CircularProgressIndicator()),
            Behaviour.error => ErrorPage(onRetry: controller.load),
            Behaviour.success => _buildBody(active!),
          },
        );
      },
    );
  }

  Widget _buildBody(ActiveModel active) {
    final l = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: EdgeInsets.all(md),
        children: [
          _buildHeader(active),
          SizedBox(height: md),
          _buildInfo(active),
          SizedBox(height: md),
          ActiveQrCardComponent(
            id: active.id,
            codigoInterno: active.codigoInterno,
            nome: active.nome,
          ),
          SizedBox(height: md),
          Text(l.activeHistory, style: ITheme.styles.subTitleBold()),
          SizedBox(height: sm),
          if (controller.history.isEmpty)
            Text(l.activeHistoryEmpty, style: ITheme.styles.bodyLight()),
          for (final item in controller.history) ActiveHistoryItem(item: item),
          if (controller.hasMoreHistory)
            Center(
              child: controller.loadingHistory
                  ? Padding(
                      padding: EdgeInsets.all(md),
                      child: CircularProgressIndicator(),
                    )
                  : TextButton(
                      onPressed: controller.loadMoreHistory,
                      child: Text(l.commonLoadMore),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ActiveModel active) {
    final l = AppLocalizations.of(context)!;
    return Card(
      color: ITheme.colors.branco,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: md,
          runSpacing: md,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: ITheme.colors.primary.withValues(alpha: 0.2),
                  child: Icon(Icons.inventory, color: ITheme.colors.primary),
                ),
                SizedBox(width: md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: xs,
                  children: [
                    Text(active.nome, style: ITheme.styles.headerBold()),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          active.codigoInterno,
                          style: ITheme.styles.bodyLight(
                            color: ITheme.colors.cinza90,
                          ),
                        ),
                        SizedBox(width: sm),
                        ActiveStatusTag(status: active.status),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: sm,
              runSpacing: sm,
              children: [
                if (controller.canMove)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: ITheme.colors.primary,
                    ),
                    onPressed: () => _openAndReload('move-active', {
                      'active': active,
                      'movements': controller.commonMovements,
                    }),
                    icon: Icon(Icons.swap_horiz),
                    label: Text(l.activeMove),
                  ),
                if (controller.canWriteOff)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ITheme.colors.alizarin,
                    ),
                    onPressed: () => _openAndReload('write-off-active', active),
                    icon: Icon(Icons.archive),
                    label: Text(l.activeWriteOff),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(ActiveModel active) {
    final l = AppLocalizations.of(context)!;
    final infos = <String, String?>{
      l.fieldType: active.tipoAtivo.nome,
      l.fieldLocation: '${active.setor.nome} (${active.localidade.nome})',
      l.fieldResponsible: active.responsavel,
      l.fieldSapCode: active.codigoSap,
      l.fieldSerialNumber: active.numeroSerie,
      l.fieldPatrimony: active.patrimonio,
      l.fieldBrand: active.marca,
      l.fieldModel: active.modelo,
      l.fieldSupplier: active.fornecedor?.nome,
      l.fieldValue: active.valor != null
          ? MoneyHelper.formatMoney(double.parse(active.valor!))
          : null,
      l.fieldEntryDate: DateHelper.toBr(active.dataEntrada),
      l.fieldAcquisitionDate: active.dataAquisicao != null
          ? DateHelper.toBr(active.dataAquisicao!)
          : null,
      l.fieldUsefulLife: active.vidaUtilMeses != null
          ? l.activeUsefulLifeValue(active.vidaUtilMeses!)
          : null,
      l.fieldLastMovement: l.activeLastMovementValue(
        DateHelper.formatDateTime(active.ultimaMovimentacaoEm),
        active.ultimaMovimentacaoPor.nome,
      ),
    };

    return Card(
      color: ITheme.colors.branco,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Wrap(
          spacing: md,
          runSpacing: md,
          children: [
            for (final info in infos.entries)
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.key,
                      style: ITheme.styles.bodySmallLight(
                        color: ITheme.colors.cinza90,
                      ),
                    ),
                    Text(
                      info.value ?? l.commonEmptyValue,
                      style: ITheme.styles.bodyBold(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
