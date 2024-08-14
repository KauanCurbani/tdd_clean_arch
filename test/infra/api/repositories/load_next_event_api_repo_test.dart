import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:advanced_flutter/infra/types/json.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoadNextEventApiRepository implements LoadNextEventRepository {
  final String url;
  final HttpGetClient httpClient;

  LoadNextEventApiRepository({required this.httpClient, required this.url});

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final response = await httpClient.get<Json>(
      url: url,
      params: {"groupId": groupId},
    );
    return NextEventMapper.fromJson(response);
  }
}

class NextEventMapper {
  static NextEvent fromJson(Json json) {
    return NextEvent(
      groupName: json["groupName"],
      date: DateTime.parse(json["date"]),
      players: NextEventPlayerMapper.fromListJson(json["players"]),
    );
  }
}

class NextEventPlayerMapper {
  static NextEventPlayer fromJson(Json json) {
    return NextEventPlayer(
      id: json["id"],
      name: json["name"],
      isConfirmed: json["isConfirmed"],
      confirmationDate: DateTime.tryParse(json["confirmationDate"] ?? ""),
      photo: json["photo"],
      position: json["position"],
    );
  }

  static List<NextEventPlayer> fromListJson(JsonArr json) {
    return json.map(fromJson).toList();
  }
}

abstract class HttpGetClient {
  Future<T> get<T>({required String url, Map<String, String>? params});
}

class HttpGetClientMock with Mock implements HttpGetClient {}

void main() {
  late String groupId;
  late String url;
  late HttpGetClient httpClient;
  late LoadNextEventApiRepository sut;
  Json jsonResponse = {
    "groupName": "Group Name",
    "date": DateTime.now().toIso8601String(),
    "players": [
      {
        "id": "1",
        "name": "Player 1",
        "isConfirmed": true,
        "confirmationDate": DateTime.now().toIso8601String(),
        "photo": "photo",
        "position": "position"
      },
      {
        "id": "2",
        "name": "Player 2",
        "isConfirmed": false,
      },
    ]
  };

  setUp(() {
    groupId = Faker().guid.guid();
    url = "https://any-url.com/api/v1/groups/:groupId/next-event";
    httpClient = HttpGetClientMock();
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);

    when(() => httpClient.get<Json>(
        url: any(named: "url"),
        params: any(named: "params"))).thenAnswer((_) async {
      return jsonResponse;
    });
  });

  test("should call httpClient with correct url", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => httpClient.get<Json>(url: url, params: any(named: "params")))
        .called(1);
  });

  test("should call httpClient with correct params", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => httpClient.get<Json>(
          url: any(named: "url"),
          params: {"groupId": groupId},
        )).called(1);
  });

  test("should return NextEvent on success", () async {
    final event = await sut.loadNextEvent(groupId: groupId);

    expect(event, isA<NextEvent>());
    expect(event.date, isA<DateTime>());
    expect(event.groupName, isA<String>());
    expect(event.players, isA<List<NextEventPlayer>>());
    expect(event.groupName, jsonResponse["groupName"]);
    expect(event.date, DateTime.parse(jsonResponse["date"]));
    expect(event.players.length, jsonResponse["players"].length);

    expect(event.players[0].id, jsonResponse["players"][0]["id"]);
    expect(event.players[0].name, jsonResponse["players"][0]["name"]);
    expect(event.players[0].isConfirmed,
        jsonResponse["players"][0]["isConfirmed"]);
    expect(event.players[0].initials, isNotEmpty);

    expect(event.players[1].id, jsonResponse["players"][1]["id"]);
    expect(event.players[1].name, jsonResponse["players"][1]["name"]);
    expect(event.players[1].isConfirmed,
        jsonResponse["players"][1]["isConfirmed"]);
    expect(event.players[1].initials, isNotEmpty);
  });

  test("should rethrow on error", () {
    when(() => httpClient.get<Json>(
        url: any(named: "url"),
        params: any(named: "params"))).thenThrow(Exception());
    final future = sut.loadNextEvent(groupId: groupId);
    expect(future, throwsA(isA<Exception>()));
  });
}
