import 'package:flutter/material.dart';
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
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalhes do Ativo'),
            actions: [
              if (controller.behaviourPage == Behaviour.success &&
                  controller.canEdit)
                IconButton(
                  tooltip: 'Editar',
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
          Text('Histórico', style: ITheme.styles.subTitleBold()),
          SizedBox(height: sm),
          if (controller.history.isEmpty)
            Text('Nenhum evento registrado.', style: ITheme.styles.bodyLight()),
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
                      child: Text('Carregar mais'),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ActiveModel active) {
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
                    label: Text('Movimentar'),
                  ),
                if (controller.canWriteOff)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ITheme.colors.alizarin,
                    ),
                    onPressed: () => _openAndReload('write-off-active', active),
                    icon: Icon(Icons.archive),
                    label: Text('Baixar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(ActiveModel active) {
    final infos = <String, String?>{
      'Tipo': active.tipoAtivo.nome,
      'Localização': '${active.setor.nome} (${active.localidade.nome})',
      'Responsável': active.responsavel,
      'Código SAP': active.codigoSap,
      'Número de série': active.numeroSerie,
      'Patrimônio': active.patrimonio,
      'Marca': active.marca,
      'Modelo': active.modelo,
      'Fornecedor': active.fornecedor?.nome,
      'Valor': active.valor != null
          ? MoneyHelper.formatMoney(double.parse(active.valor!))
          : null,
      'Data de entrada': DateHelper.toBr(active.dataEntrada),
      'Data de aquisição': active.dataAquisicao != null
          ? DateHelper.toBr(active.dataAquisicao!)
          : null,
      'Vida útil': active.vidaUtilMeses != null
          ? '${active.vidaUtilMeses} meses'
          : null,
      'Última movimentação':
          '${DateHelper.formatDateTime(active.ultimaMovimentacaoEm)} por ${active.ultimaMovimentacaoPor.nome}',
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
                    Text(info.value ?? '—', style: ITheme.styles.bodyBold()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
