import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';
import 'package:iveco_find/src/shared/components/i_button.dart';
import 'package:iveco_find/src/shared/components/i_drop_down.dart';
import 'package:iveco_find/src/shared/components/i_snackbar.dart';
import 'package:iveco_find/src/shared/components/i_text_field.dart';
import 'package:iveco_find/src/shared/utils/formatters/date_formatter.dart';
import 'package:iveco_find/src/shared/utils/formatters/money_formatter.dart';

class RegisterActivityPage extends StatefulWidget {
  const RegisterActivityPage({super.key});

  @override
  State<RegisterActivityPage> createState() => _RegisterActivityPageState();
}

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Ativo')),
      body: Padding(
        padding: EdgeInsets.all(md),
        child: Wrap(
          spacing: md,
          runSpacing: md,
          children: [
            SizedBox(
              width: width * 0.4,
              child: ITextField(label: 'Nome do Ativo', onChanged: (value) {}),
            ),
            SizedBox(
              width: width * 0.4,
              child: ITextField(label: 'Código interno', onChanged: (value) {}),
            ),
            SizedBox(
              width: 200,
              child: ITextField(label: 'Código SAP', onChanged: (value) {}),
            ),

            SizedBox(
              width: width * 0.3,
              child: IDropDown(
                label: 'Tipo do Ativo',
                items: ['Ativo', 'Ferramenta', 'Peça'],
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              width: width * 0.6,
              child: IDropDown(
                label: 'Localização',
                items: ['Mecanica (Sete Lagoas)', 'Almoxarifado', 'Oficina'],
                onChanged: (value) {},
              ),
            ),
            ITextField(label: 'Responsável', onChanged: (value) {}),
            SizedBox(
              width: width * 0.3,
              child: ITextField(
                label: 'Valor',
                inputFormatters: [MoneyInputFormatter()],
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              width: width * 0.3,
              child: ITextField(
                label: 'Data de Aquisição',
                inputFormatters: [DateInputFormatter()],
                onChanged: (value) {},
              ),
            ),
            SizedBox(
              width: width * 0.3,
              child: ITextField(label: 'Fornecedor', onChanged: (value) {}),
            ),
            SizedBox(
              width: width * 0.3,
              child: ITextField(label: 'Vida Útil', onChanged: (value) {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(md),
        child: IButton.primary(
          text: 'Cadastrar',
          onTap: () {
            SnackBarUtils.showSnackBarSuccess(
              context,
              'Ativo Cadastrado com sucesso!',
            );
            context.pop();
          },
        ),
      ),
    );
  }
}
