import 'package:flutter/material.dart';
import 'package:iveco_find/l10n/app_localizations.dart';

enum ActiveStatus {
  disponivel('DISPONIVEL', Colors.green),
  emUso('EM_USO', Colors.blue),
  emManutencao('EM_MANUTENCAO', Colors.orange),
  baixado('BAIXADO', Colors.grey);

  final String value;
  final Color color;

  const ActiveStatus(this.value, this.color);

  String label(AppLocalizations l) => switch (this) {
    ActiveStatus.disponivel => l.activeStatusAvailable,
    ActiveStatus.emUso => l.activeStatusInUse,
    ActiveStatus.emManutencao => l.activeStatusInMaintenance,
    ActiveStatus.baixado => l.activeStatusWrittenOff,
  };

  static ActiveStatus fromValue(String value) {
    return ActiveStatus.values.firstWhere((e) => e.value == value);
  }
}
