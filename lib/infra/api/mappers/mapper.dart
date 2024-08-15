import 'package:advanced_flutter/infra/types/json.dart';

abstract base class Mapper<Entity> {
  List<Entity> fromListJson(JsonArr json) {
    return json.map(fromJson).toList();
  }

  Entity fromJson(Json json);
}
