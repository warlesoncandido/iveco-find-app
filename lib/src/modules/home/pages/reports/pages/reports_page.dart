import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.reportsTitle,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
