import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';

void main() {
  // Mesma matriz de src/shared/permissoes.ts da API.
  Set<String> values(String? perfil) =>
      Permission.forProfile(perfil).map((e) => e.value).toSet();

  const base = {'conta:propria', 'ativos:ler', 'cadastros:ler'};
  const operacao = {...base, 'ativos:escrever', 'ativos:movimentar'};

  test('ADMINISTRADOR tem todas as permissões', () {
    expect(values('ADMINISTRADOR'), {
      ...operacao,
      'ativos:baixar',
      'ativos:excluir',
      'cadastros:gerir',
      'usuarios:gerir',
    });
  });

  test('GESTOR = operação + baixar', () {
    expect(values('GESTOR'), {...operacao, 'ativos:baixar'});
  });

  test('OPERACIONAL = operação', () {
    expect(values('OPERACIONAL'), operacao);
  });

  test('CONSULTA só lê', () {
    expect(values('CONSULTA'), base);
  });

  test('perfil desconhecido ou ausente não tem permissão', () {
    expect(values(null), isEmpty);
    expect(values('OUTRO'), isEmpty);
  });
}
