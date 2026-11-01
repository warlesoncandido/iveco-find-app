import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/enums/movement_type.dart';

class ValidMovementModel {
  final MovementType tipo;
  final ActiveStatus statusDestino;
  final SectionRule setor;
  final bool exigeObservacao;

  ValidMovementModel({
    required this.tipo,
    required this.statusDestino,
    required this.setor,
    required this.exigeObservacao,
  });

  factory ValidMovementModel.fromJson(Map<String, dynamic> json) {
    return ValidMovementModel(
      tipo: MovementType.fromValue(json['tipo'] as String),
      statusDestino: ActiveStatus.fromValue(json['statusDestino'] as String),
      setor: SectionRule.fromValue(json['setor'] as String),
      exigeObservacao: json['exigeObservacao'] as bool,
    );
  }
}
