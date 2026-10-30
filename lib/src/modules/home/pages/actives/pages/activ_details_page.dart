import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';

class ActivDetailsPage extends StatefulWidget {
  const ActivDetailsPage({super.key});

  @override
  State<ActivDetailsPage> createState() => _ActivDetailsPageState();
}

class _ActivDetailsPageState extends State<ActivDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text('Detalhes do Ativo')),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Nome do Ativo',
                          style: ITheme.styles.bodyLight(),
                        ),
                        subtitle: Text(
                          'Chave de Fenda',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                      ListTile(
                        title: Text('Código Interno'),
                        subtitle: Text(
                          '12345',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                      ListTile(
                        title: Text('Código SAP'),
                        subtitle: Text(
                          '67890',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                      ListTile(
                        title: Text('Tipo do Ativo'),
                        subtitle: Text(
                          'Ativo',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                      ListTile(
                        title: Text('Localização'),
                        subtitle: Text(
                          'Mecânica (Sete Lagoas)',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                      ListTile(
                        title: Text('Responsável'),
                        subtitle: Text(
                          'João da Silva',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                      ListTile(
                        title: Text('Valor'),
                        subtitle: Text(
                          'R\$ 1.000,00',
                          style: ITheme.styles.bodyBold(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Qr Code', style: ITheme.styles.bodyBold()),
                          PopupMenuButton(
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text('Imprimir Qr Code'),
                                  onTap: () {},
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/3/38/Qr-code-ver-10.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=original',
                        width: 250,
                        height: 250,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            TabBar(
              tabs: [
                Tab(text: 'Histórico'),
                Tab(text: 'Documentos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: sm,
                      children: [
                        Text(
                          '01/01/2024 - Mecânica (Sete Lagoas) - Responsável: João da Silva',
                          style: ITheme.styles.bodyRegular(),
                        ),
                        Text(
                          '15/02/2024 - Almoxarifado - Responsável: Maria Oliveira',
                          style: ITheme.styles.bodyRegular(),
                        ),
                        Text(
                          '29/04/2024 - Mecânica (Sete Lagoas) - Responsável: João da Silva',
                          style: ITheme.styles.bodyRegular(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      spacing: md,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.picture_as_pdf, size: 50),
                            SizedBox(width: 10),
                            Text('nota.pdf', style: ITheme.styles.bodyBold()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.picture_as_pdf, size: 50),
                            SizedBox(width: 10),
                            Text(
                              'manutenção-01.pdf',
                              style: ITheme.styles.bodyBold(),
                            ),
                          ],
                        ),
                      ],
                    ),
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
