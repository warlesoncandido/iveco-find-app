import 'package:flutter/material.dart';

enum ActiveStatus {
  disponivel('DISPONIVEL', 'Disponível', Colors.green),
  emUso('EM_USO', 'Em uso', Colors.blue),
  emManutencao('EM_MANUTENCAO', 'Em manutenção', Colors.orange),
  baixado('BAIXADO', 'Baixado', Colors.grey);

  final String value;
  final String label;
  final Color color;

  const ActiveStatus(this.value, this.label, this.color);

  static ActiveStatus fromValue(String value) {
    return ActiveStatus.values.firstWhere((e) => e.value == value);
  }
}
