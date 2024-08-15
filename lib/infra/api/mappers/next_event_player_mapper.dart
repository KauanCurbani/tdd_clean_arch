import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/api/mappers/mapper.dart';
import 'package:advanced_flutter/infra/types/json.dart';

final class NextEventPlayerMapper extends Mapper<NextEventPlayer> {
  @override
  NextEventPlayer fromJson(Json json) {
    return NextEventPlayer(
      id: json["id"],
      name: json["name"],
      isConfirmed: json["isConfirmed"],
      confirmationDate: DateTime.tryParse(json["confirmationDate"] ?? ""),
      photo: json["photo"],
      position: json["position"],
    );
  }
}
