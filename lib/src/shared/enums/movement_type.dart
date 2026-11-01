enum MovementType {
  entrada('ENTRADA', 'Entrada'),
  transferencia('TRANSFERENCIA', 'Transferência'),
  saidaParaUso('SAIDA_PARA_USO', 'Saída para uso'),
  devolucao('DEVOLUCAO', 'Devolução'),
  envioManutencao('ENVIO_MANUTENCAO', 'Envio para manutenção'),
  retornoManutencao('RETORNO_MANUTENCAO', 'Retorno de manutenção'),
  baixa('BAIXA', 'Baixa');

  final String value;
  final String label;

  const MovementType(this.value, this.label);

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
