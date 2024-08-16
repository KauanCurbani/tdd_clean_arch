abstract base class Mapper<Entity> {
  List<Entity> fromListJson(List<dynamic> json) {
    return json.map<Entity>(fromJson).toList();
  }

  Entity fromJson(dynamic json);
}
