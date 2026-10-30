import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivesTable extends StatefulWidget {
  const ActivesTable({super.key, required this.onTapRow});

  final void Function(Map<String, String> rowData) onTapRow;

  @override
  State<ActivesTable> createState() => _ActivesTableState();
}

class _ActivesTableState extends State<ActivesTable> {
  int? expandedIndex;
  int currentPage = 0;

  static const int pageSize = 5;

  final List<Map<String, String>> professionals = [
    {
      'id': '1',
      'nome': 'Chave de Fenda',
      'codigo': '28',
      'localidade': 'Almoxarifado',
      'status': 'Ativo',
    },
    {
      'id': '2',
      'nome': 'Martelo',
      'codigo': '35',
      'localidade': 'Mecanica',
      'status': 'Ativo',
    },
    {
      'id': '3',
      'nome': 'Alicate',
      'codigo': '42',
      'localidade': 'Mecanica',
      'status': 'Ativo',
    },
    {
      'id': '4',
      'nome': 'Chave Inglesa',
      'codigo': '51',
      'localidade': 'Mecanica',
      'status': 'Ativo',
    },
    {
      'id': '5',
      'nome': 'Serra Manual',
      'codigo': '63',
      'localidade': 'Mecanica',
      'status': 'Ativo',
    },
    {
      'id': '6',
      'nome': 'Furadeira Elétrica',
      'codigo': '74',
      'localidade': 'Mecanica',
      'status': 'Inativo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final start = currentPage * pageSize;
    final end = (start + pageSize).clamp(0, professionals.length);
    final items = professionals.sublist(start, end);

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
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
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Ativo')),
                        DataColumn(label: Text('Código SAP')),
                        DataColumn(label: Text('Localidade')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Ação')),
                      ],
                      rows: [
                        for (int i = 0; i < items.length; i++)
                          DataRow(
                            color: WidgetStateProperty.resolveWith((states) {
                              if (expandedIndex == start + i) {
                                return primary.withValues(alpha: 0.08);
                              }

                              if (i.isOdd) {
                                return theme.colorScheme.surfaceContainerLow;
                              }

                              return null;
                            }),
                            cells: [
                              DataCell(Text(items[i]['id']!)),
                              DataCell(
                                Text(
                                  items[i]['nome']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(Text(items[i]['codigo']!)),
                              DataCell(Text(items[i]['localidade']!)),
                              DataCell(Text(items[i]['status']!)),

                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Ver detalhes',
                                      icon: Icon(Icons.visibility),
                                      onPressed: () {
                                        widget.onTapRow(items[i]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Detalhes expansíveis
            if (expandedIndex != null &&
                expandedIndex! >= start &&
                expandedIndex! < end)
              _buildDetails(items[expandedIndex! - start], primary, theme),

            const Divider(height: 1),

            // Paginação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Text(
                    professionals.isEmpty
                        ? 'Nenhum registro'
                        : '${start + 1}–$end de ${professionals.length} registros',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Página anterior',
                        onPressed: currentPage > 0
                            ? () {
                                setState(() {
                                  currentPage--;
                                  expandedIndex = null;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${currentPage + 1}',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Próxima página',
                        onPressed: end < professionals.length
                            ? () {
                                setState(() {
                                  currentPage++;
                                  expandedIndex = null;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(
    Map<String, String> professional,
    Color primary,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes do profissional',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow('Nome', professional['nome']!),
          _detailRow('Idade', professional['idade']!),
          _detailRow('Cargo', professional['cargo']!),
          _detailRow('E-mail', professional['email']!),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
