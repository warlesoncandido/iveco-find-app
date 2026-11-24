import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';

/// Diálogo de busca de Ativo para associar ao Kit. Devolve o Ativo escolhido ou `null`.
Future<ActiveSummaryModel?> showKitAddItemDialog(
  BuildContext context, {
  required Future<List<ActiveSummaryModel>> Function(String query) search,
}) {
  return showDialog<ActiveSummaryModel>(
    context: context,
    builder: (context) => KitAddItemDialog(search: search),
  );
}

class KitAddItemDialog extends StatefulWidget {
  final Future<List<ActiveSummaryModel>> Function(String query) search;
  const KitAddItemDialog({super.key, required this.search});

  @override
  State<KitAddItemDialog> createState() => _KitAddItemDialogState();
}

class _KitAddItemDialogState extends State<KitAddItemDialog> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<ActiveSummaryModel> _items = [];
  bool _loading = true;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() => _loading = true);
    final items = await widget.search(_query.text.trim());
    if (!mounted || request != _request) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.kitAddItemTitle),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l.kitAddItemSearch,
              ),
            ),
            SizedBox(height: sm),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? Center(
                      child: Text(
                        l.kitAddItemEmpty,
                        style: ITheme.styles.bodyLight(),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          title: Text(item.nome),
                          subtitle: Text(
                            '${item.codigoInterno} · ${item.tipoAtivo.nome}',
                          ),
                          trailing: ActiveStatusTag(status: item.status),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
      ],
    );
  }
}
