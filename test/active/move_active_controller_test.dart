import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/move_active_controller.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';

import '../user/fakes.dart';

final _current = RefModel(id: 's1', nome: 'Almoxarifado', ativo: true);
final _other = RefModel(id: 's2', nome: 'Oficina', ativo: true);

ActiveModel _active() => ActiveModel.fromJson({
  'id': 'a1',
  'codigoInterno': 'FER-000123',
  'nome': 'Furadeira',
  'tipoAtivo': {'id': 't1', 'nome': 'Ferramenta', 'ativo': true},
  'setor': {'id': 's1', 'nome': 'Almoxarifado', 'ativo': true},
  'localidade': {'id': 'l1', 'nome': 'Sete Lagoas', 'ativo': true},
  'status': 'DISPONIVEL',
  'dataEntrada': '2026-01-10',
  'ultimaMovimentacaoEm': '2026-01-10T12:00:00Z',
  'ultimaMovimentacaoPor': {'id': 'u1', 'nome': 'Maria', 'ativo': true},
  'versao': 1,
  'criadoEm': '2026-01-10T12:00:00Z',
  'atualizadoEm': '2026-01-10T12:00:00Z',
});

void main() {
  late MoveActiveController controller;

  setUp(() {
    final dio = FakeClientDio();
    controller =
        MoveActiveController(
            repository: ActiveRepository(dio: dio),
            locationRepository: LocationRepository(dio: dio),
            sectionRepository: SectionRepository(dio: dio),
          )
          ..active = _active()
          ..movement = ValidMovementModel(
            tipo: MovementType.transferencia,
            statusDestino: ActiveStatus.disponivel,
            setor: SectionRule.obrigatorio,
            exigeObservacao: false,
          );
  });

  tearDown(() => L10n.locale = LocaleController.portugueseBrazil);

  final cases = {
    LocaleController.portugueseBrazil: (
      required: 'Selecione o setor de destino.',
      different: 'Selecione um setor diferente do atual.',
    ),
    LocaleController.spanish: (
      required: 'Selecciona el sector de destino.',
      different: 'Selecciona un sector diferente del actual.',
    ),
  };

  for (final entry in cases.entries) {
    group('validateSection (${entry.key})', () {
      setUp(() => L10n.locale = entry.key);

      test('sem setor selecionado → mensagem de obrigatório', () {
        expect(controller.validateSection(null), entry.value.required);
      });

      test('mesmo setor do atual → pede um setor diferente', () {
        expect(controller.validateSection(_current), entry.value.different);
      });

      test('setor diferente do atual → válido', () {
        expect(controller.validateSection(_other), isNull);
      });
    });
  }
}
