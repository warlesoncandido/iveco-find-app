import 'package:flutter/material.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/active_status_tag.dart';
import 'package:iveco_find/src/shared/models/active_summary_model.dart';

class ActivesTable extends StatelessWidget {
  const ActivesTable({super.key, required this.items, required this.onTapRow});

  final List<ActiveSummaryModel> items;
  final void Function(ActiveSummaryModel item) onTapRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Center(
        child: Text(
          'Nenhum ativo encontrado.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStatePropertyAll(
                      theme.colorScheme.surfaceContainerHighest,
                    ),
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 64,
                    headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    columnSpacing: 32,
                    horizontalMargin: 20,
                    columns: const [
                      DataColumn(label: Text('Código')),
                      DataColumn(label: Text('Ativo')),
                      DataColumn(label: Text('Tipo')),
                      DataColumn(label: Text('Localização')),
                      DataColumn(label: Text('Responsável')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Ação')),
                    ],
                    rows: [
                      for (int i = 0; i < items.length; i++)
                        DataRow(
                          onSelectChanged: (_) => onTapRow(items[i]),
                          color: WidgetStateProperty.resolveWith((states) {
                            if (i.isOdd) {
                              return theme.colorScheme.surfaceContainerLow;
                            }
                            return null;
                          }),
                          cells: [
                            DataCell(Text(items[i].codigoInterno)),
                            DataCell(
                              Text(
                                items[i].nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(Text(items[i].tipoAtivo.nome)),
                            DataCell(
                              Text(
                                '${items[i].setor.nome} (${items[i].localidade.nome})',
                              ),
                            ),
                            DataCell(Text(items[i].responsavel ?? '—')),
                            DataCell(ActiveStatusTag(status: items[i].status)),
                            DataCell(
                              IconButton(
                                tooltip: 'Ver detalhes',
                                icon: Icon(Icons.visibility),
                                onPressed: () => onTapRow(items[i]),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
