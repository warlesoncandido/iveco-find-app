import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_attachments_tab.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_history_item.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_qr_card_component.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_attachments_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/active_details_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/kit_add_item_dialog.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';
import 'package:iveco_find/src/shared/pages/error_page.dart';
import 'package:iveco_find/src/shared/utils/messegers/snackbar_util.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/helpers/date_helper.dart';
import 'package:iveco_find/src/shared/utils/helpers/money_helper.dart';

/// (Re)carrega a ficha e a aba Arquivos do Ativo [id]. Os controllers são únicos:
/// ao voltar da ficha de outro Ativo (Kit ou item), os dois precisam voltar a este.
@visibleForTesting
void initActiveDetails(
  String id, {
  required ActiveDetailsController details,
  required ActiveAttachmentsController attachments,
}) {
  details.init(id);
  attachments.init(id);
}

class ActiveDetailsPage extends StatefulWidget {
  final String id;
  const ActiveDetailsPage({super.key, required this.id});

  @override
  State<ActiveDetailsPage> createState() => _ActiveDetailsPageState();
}

class _ActiveDetailsPageState extends State<ActiveDetailsPage> {
  final controller = GetIt.instance.get<ActiveDetailsController>();
  final attachmentsController = GetIt.instance
      .get<ActiveAttachmentsController>();

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _openAndReload(String name, Object extra) async {
    final result = await context.pushNamed(name, extra: extra);
    if (result != null) {
      controller.load();
    }
  }

  /// Abre a ficha de outro Ativo (Kit ou item). O controller é único: ao voltar,
  /// recarrega esta ficha.
  Future<void> _openActive(String id) async {
    await context.pushNamed('active-details', extra: id);
    if (mounted) _init();
  }

  void _init() => initActiveDetails(
    widget.id,
    details: controller,
    attachments: attachmentsController,
  );

  Future<void> _addKitItem() async {
    final l = AppLocalizations.of(context)!;
    final item = await showKitAddItemDialog(
      context,
      search: controller.searchKitCandidates,
    );
    if (item == null || !mounted) return;
    await controller.addKitItem(
      item,
      onSuccess: () {
        if (!mounted) return;
        SnackbarUtil.showSuccess(context, message: l.kitAddItemSuccess);
      },
      onError: (message) {
        if (!mounted) return;
        SnackbarUtil.showError(context, message: message);
      },
    );
  }

  Future<void> _removeKitItem(ActiveSummaryModel item) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.kitRemoveConfirmTitle),
        content: Text(l.kitRemoveConfirmMessage(item.codigoInterno)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.kitRemoveItem),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await controller.removeKitItem(
      item,
      onSuccess: () {
        if (!mounted) return;
        SnackbarUtil.showSuccess(context, message: l.kitRemoveItemSuccess);
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
      builder: (context, value) {
        final active = controller.active;
        final l = AppLocalizations.of(context)!;
        final loaded = controller.behaviourPage == Behaviour.success;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.activeDetailsTitle),
              bottom: loaded
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(kTextTabBarHeight),
                      child: ColoredBox(
                        color: ITheme.colors.branco,
                        child: TabBar(
                          labelColor: ITheme.colors.textColor,
                          unselectedLabelColor: ITheme.colors.textColor
                              .withValues(alpha: 0.6),
                          indicatorColor: ITheme.colors.textColor,
                          dividerColor: ITheme.colors.cinza225,
                          tabs: [
                            Tab(text: l.activeTabDetails),
                            Tab(text: l.activeTabFiles),
                          ],
                        ),
                      ),
                    )
                  : null,
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
              Behaviour.success => TabBarView(
                children: [
                  _buildBody(active!),
                  ActiveAttachmentsTab(
                    controller: attachmentsController,
                    canEdit: controller.canEdit,
                  ),
                ],
              ),
            },
          ),
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
          if (active.kit != null) ...[
            SizedBox(height: md),
            _buildKitMembership(active.kit!),
          ],
          SizedBox(height: md),
          _buildInfo(active),
          if (active.isKit) ...[SizedBox(height: md), _buildKitItems(active)],
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

  /// Item de Kit: aviso de pertencimento, com atalho para a ficha do Kit.
  Widget _buildKitMembership(KitRefModel kit) {
    final l = AppLocalizations.of(context)!;
    return Card(
      color: ITheme.colors.primary.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(Icons.inventory_2, color: ITheme.colors.primary),
        title: Text(
          l.kitBelongsTo(kit.codigoInterno, kit.nome),
          style: ITheme.styles.bodyBold(),
        ),
        subtitle: Text(l.kitBelongsToHint),
        trailing: TextButton.icon(
          onPressed: () => _openActive(kit.id),
          icon: Icon(Icons.open_in_new),
          label: Text(l.kitOpen),
        ),
      ),
    );
  }

  /// Kit: itens associados, com destaque para os que estão em Status diferente.
  Widget _buildKitItems(ActiveModel kit) {
    final l = AppLocalizations.of(context)!;
    return Card(
      color: ITheme.colors.branco,
      child: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l.kitItemsTitle} (${kit.items.length})',
                    style: ITheme.styles.subTitleBold(),
                  ),
                ),
                if (controller.canManageKitItems)
                  TextButton.icon(
                    onPressed: _addKitItem,
                    icon: Icon(Icons.add),
                    label: Text(l.kitAddItem),
                  ),
              ],
            ),
            if (kit.items.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: sm),
                child: Text(l.kitItemsEmpty, style: ITheme.styles.bodyLight()),
              ),
            for (final item in kit.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => _openActive(item.id),
                leading: item.status != kit.status
                    ? Tooltip(
                        message: l.kitItemDifferentStatus,
                        child: Icon(
                          Icons.warning_amber,
                          color: ITheme.colors.alizarin,
                        ),
                      )
                    : Icon(Icons.build_outlined),
                title: Text(item.nome),
                subtitle: Text(
                  item.status != kit.status
                      ? '${item.codigoInterno} · ${l.kitItemDifferentStatus}'
                      : item.codigoInterno,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ActiveStatusTag(status: item.status),
                    if (controller.canManageKitItems)
                      IconButton(
                        tooltip: l.kitRemoveItem,
                        icon: Icon(Icons.link_off),
                        onPressed: () => _removeKitItem(item),
                      ),
                  ],
                ),
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
