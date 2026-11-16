import 'package:iveco_find/l10n/app_localizations.dart';

enum MovementType {
  entrada('ENTRADA'),
  transferencia('TRANSFERENCIA'),
  saidaParaUso('SAIDA_PARA_USO'),
  devolucao('DEVOLUCAO'),
  envioManutencao('ENVIO_MANUTENCAO'),
  retornoManutencao('RETORNO_MANUTENCAO'),
  baixa('BAIXA');

  final String value;

  const MovementType(this.value);

  String label(AppLocalizations l) => switch (this) {
    MovementType.entrada => l.movementEntry,
    MovementType.transferencia => l.movementTransfer,
    MovementType.saidaParaUso => l.movementCheckout,
    MovementType.devolucao => l.movementReturn,
    MovementType.envioManutencao => l.movementSendToMaintenance,
    MovementType.retornoManutencao => l.movementReturnFromMaintenance,
    MovementType.baixa => l.movementWriteOff,
  };

  static MovementType fromValue(String value) {
    return MovementType.values.firstWhere((e) => e.value == value);
  }
}

/// Regra do Setor de destino de uma Movimentação (AD-8 da API).
enum SectionRule {
  obrigatorio('OBRIGATORIO'),
  opcional('OPCIONAL'),
  proibido('PROIBIDO');

  final String value;

  const SectionRule(this.value);

  static SectionRule fromValue(String value) {
    return SectionRule.values.firstWhere((e) => e.value == value);
  }
}
