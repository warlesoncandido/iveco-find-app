import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/pages/actives/controllers/move_active_controller.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';
import 'package:iveco_find/src/shared/models/active_model.dart';
import 'package:iveco_find/src/shared/models/ref_model.dart';
import 'package:iveco_find/src/shared/models/type_model.dart';
import 'package:iveco_find/src/shared/models/valid_movement_model.dart';
import 'package:iveco_find/src/shared/params/type_params.dart';
import 'package:iveco_find/src/shared/repositories/active_repository.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';

import '../user/fakes.dart';

Map<String, dynamic> _ref(String id, String nome) => {
  'id': id,
  'nome': nome,
  'ativo': true,
};

Map<String, dynamic> _summary(
  String id,
  String status, {
  String setor = 's1',
}) => {
  'id': id,
  'codigoInterno': 'FER-$id',
  'nome': 'Ferramenta $id',
  'status': status,
  'tipoAtivo': _ref('t1', 'Ferramenta'),
  'categoria': null,
  'setor': _ref(setor, 'Setor $setor'),
  'localidade': _ref('l1', 'Sete Lagoas'),
  'responsavel': null,
  'ultimaMovimentacaoEm': '2026-01-10T12:00:00Z',
  'versao': 2,
};

Map<String, dynamic> _detail({
  String status = 'DISPONIVEL',
  bool ehKit = true,
  Map<String, dynamic>? kit,
  List<Map<String, dynamic>> itens = const [],
}) => {
  'id': 'k1',
  'codigoInterno': 'CAR-000001',
  'nome': 'Carrinho',
  'tipoAtivo': _ref('tk', 'Carrinho'),
  'setor': _ref('s1', 'Almoxarifado'),
  'localidade': _ref('l1', 'Sete Lagoas'),
  'status': status,
  'dataEntrada': '2026-01-10',
  'ultimaMovimentacaoEm': '2026-01-10T12:00:00Z',
  'ultimaMovimentacaoPor': _ref('u1', 'Maria'),
  'versao': 1,
  'criadoEm': '2026-01-10T12:00:00Z',
  'atualizadoEm': '2026-01-10T12:00:00Z',
  'ehKit': ehKit,
  'kit': kit,
  'itens': itens,
};

void main() {
  group('ActiveModel: Kit', () {
    test(
      'lê ehKit, kit e itens; separa itens no mesmo Status e em Status diferente',
      () {
        final kit = ActiveModel.fromJson(
          _detail(
            itens: [
              _summary('i1', 'DISPONIVEL'),
              _summary('i2', 'EM_MANUTENCAO'),
            ],
          ),
        );
        expect(kit.isKit, isTrue);
        expect(kit.isKitItem, isFalse);
        expect(kit.items.map((e) => e.id), ['i1', 'i2']);
        expect(kit.itemsSameStatus.map((e) => e.id), ['i1']);
        expect(kit.itemsDifferentStatus.map((e) => e.id), ['i2']);
      },
    );

    test('item: kit preenchido e sem itens', () {
      final item = ActiveModel.fromJson(
        _detail(
          ehKit: false,
          kit: {
            'id': 'k9',
            'codigoInterno': 'CAR-000009',
            'nome': 'Carrinho 9',
          },
        ),
      );
      expect(item.isKitItem, isTrue);
      expect(item.kit!.codigoInterno, 'CAR-000009');
      expect(item.kit!.nome, 'Carrinho 9');
      expect(item.items, isEmpty);
    });

    test('resposta sem os campos novos (API antiga) → defaults', () {
      final json = _detail()
        ..remove('ehKit')
        ..remove('kit')
        ..remove('itens');
      final active = ActiveModel.fromJson(json);
      expect(active.isKit, isFalse);
      expect(active.kit, isNull);
      expect(active.items, isEmpty);
    });
  });

  group('ActiveRepository: itens do Kit', () {
    late FakeClientDio dio;
    late ActiveRepository repository;

    setUp(() {
      dio = FakeClientDio();
      repository = ActiveRepository(dio: dio);
    });

    test(
      'addKitItem → POST /ativos/{kit}/itens com itemId e a versão do item',
      () async {
        dio.response = _detail(itens: [_summary('i1', 'DISPONIVEL')]);
        final result = await repository.addKitItem(
          kitId: 'k1',
          itemId: 'i1',
          itemVersion: 2,
        );
        final kit = result.getOrElse(() => throw StateError('falhou'));
        expect(kit.items.single.id, 'i1');
        final call = dio.calls.single;
        expect(call.method, 'POST');
        expect(call.path, '/api/v1/ativos/k1/itens');
        expect(call.data, {'itemId': 'i1', 'versao': 2});
        expect(call.isAuth, isTrue);
      },
    );

    test(
      'removeKitItem → POST /ativos/{kit}/itens/{item}/remocao com a versão do item',
      () async {
        dio.response = _detail();
        final result = await repository.removeKitItem(
          kitId: 'k1',
          itemId: 'i1',
          itemVersion: 3,
        );
        expect(result.isRight(), isTrue);
        final call = dio.calls.single;
        expect(call.path, '/api/v1/ativos/k1/itens/i1/remocao');
        expect(call.data, {'versao': 3});
      },
    );

    test(
      '422 KIT_ASSOCIACAO_INVALIDA → Failure com o detail e o código',
      () async {
        dio.error = problemDetails(
          422,
          'KIT_ASSOCIACAO_INVALIDA',
          'O item já pertence a outro Kit',
        );
        final result = await repository.addKitItem(
          kitId: 'k1',
          itemId: 'i1',
          itemVersion: 2,
        );
        final failure = result.fold(
          (l) => l,
          (r) => throw StateError('não falhou'),
        );
        expect(failure.message, 'O item já pertence a outro Kit');
        expect(failure.code, 'KIT_ASSOCIACAO_INVALIDA');
      },
    );
  });

  group('Tipo de Ativo: kit', () {
    test('TypeModel lê kit (ausente = false) e TypeParams envia kit', () {
      final json = {
        'id': 't1',
        'nome': 'Carrinho',
        'prefixo': 'CAR',
        'kit': true,
        'ativo': true,
        'criadoEm': '2026-01-10T12:00:00Z',
        'atualizadoEm': '2026-01-10T12:00:00Z',
      };
      expect(TypeModel.fromJson(json).kit, isTrue);
      expect(TypeModel.fromJson({...json}..remove('kit')).kit, isFalse);
      expect(TypeParams(name: 'Carrinho', prefix: 'CAR', kit: true).toJson(), {
        'nome': 'Carrinho',
        'prefixo': 'CAR',
        'kit': true,
      });
    });
  });

  group('MoveActiveController: itens que acompanham o Kit', () {
    MoveActiveController controllerFor(
      ActiveModel kit,
      ValidMovementModel movement,
    ) {
      final dio = FakeClientDio();
      return MoveActiveController(
          repository: ActiveRepository(dio: dio),
          locationRepository: LocationRepository(dio: dio),
          sectionRepository: SectionRepository(dio: dio),
        )
        ..active = kit
        ..movement = movement;
    }

    final kit = ActiveModel.fromJson(
      _detail(
        itens: [
          _summary('i1', 'DISPONIVEL'),
          _summary('i2', 'DISPONIVEL', setor: 's2'),
          _summary('i3', 'EM_MANUTENCAO'),
        ],
      ),
    );

    test('Saída: acompanham os do mesmo Status; os demais ficam para trás', () {
      final c = controllerFor(
        kit,
        ValidMovementModel(
          tipo: MovementType.saidaParaUso,
          statusDestino: ActiveStatus.emUso,
          setor: SectionRule.opcional,
          exigeObservacao: false,
        ),
      );
      expect(c.followingItems.map((e) => e.id), ['i1', 'i2']);
      expect(c.leftBehindItems.map((e) => e.id), ['i3']);
    });

    test(
      'Transferência: item já no Setor de destino não muda nem conta como deixado para trás',
      () {
        final c = controllerFor(
          kit,
          ValidMovementModel(
            tipo: MovementType.transferencia,
            statusDestino: ActiveStatus.disponivel,
            setor: SectionRule.obrigatorio,
            exigeObservacao: false,
          ),
        )..section = RefModel(id: 's2', nome: 'Oficina', ativo: true);
        expect(c.followingItems.map((e) => e.id), ['i1']);
        expect(c.leftBehindItems.map((e) => e.id), ['i3']);
      },
    );

    test('Ativo que não é Kit: nenhum item', () {
      final c = controllerFor(
        ActiveModel.fromJson(_detail(ehKit: false)),
        ValidMovementModel(
          tipo: MovementType.saidaParaUso,
          statusDestino: ActiveStatus.emUso,
          setor: SectionRule.opcional,
          exigeObservacao: false,
        ),
      );
      expect(c.followingItems, isEmpty);
      expect(c.leftBehindItems, isEmpty);
    });
  });
}
