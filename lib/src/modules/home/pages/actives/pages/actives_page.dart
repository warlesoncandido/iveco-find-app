import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/modules/home/pages/actives/components/actives_table.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';

class ActivesPage extends StatefulWidget {
  const ActivesPage({super.key});

  @override
  State<ActivesPage> createState() => _ActivesPageState();
}

class _ActivesPageState extends State<ActivesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(md),
        child: Column(
          children: [
            ITextField(
              label: 'Pesquisar Ativos',
              suffixIcon: Icon(Icons.search),
              onChanged: (value) {
                // Handle search logic here
              },
            ),
            SizedBox(height: md),
            ActivesTable(
              onTapRow: (rowData) {
                context.pushNamed('active-details', extra: rowData);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('register-activity');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
