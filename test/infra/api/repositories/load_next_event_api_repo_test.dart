import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class LoadNextEventApiRepository implements LoadNextEventRepository {
  final String url;
  final HttpGetClient httpClient;

  LoadNextEventApiRepository({required this.httpClient, required this.url});

  @override
  Future<NextEvent> loadNextEvent({required String groupId}) async {
    final response = await httpClient.get(
      url: url,
      params: {"groupId": groupId},
    );
    return NextEvent(
      groupName: response["groupName"],
      date: DateTime.parse(response["date"]),
      players: (response["players"] as List)
          .map((player) => NextEventPlayer(
                id: player["id"],
                name: player["name"],
                isConfirmed: player["isConfirmed"],
                confirmationDate:
                    DateTime.tryParse(player["confirmationDate"] ?? ""),
                photo: player["photo"],
                position: player["position"],
              ))
          .toList(),
    );
  }
}

abstract class HttpGetClient {
  Future<dynamic> get({required String url, Map<String, String>? params});
}

class HttpGetClientMock with Mock implements HttpGetClient {}

void main() {
  late String groupId;
  late String url;
  late HttpGetClient httpClient;
  late LoadNextEventApiRepository sut;
  Map<String, dynamic> jsonResponse = {
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

    when(() => httpClient.get(
        url: any(named: "url"),
        params: any(named: "params"))).thenAnswer((_) async {
      return jsonResponse;
    });
  });

  test("should call httpClient with correct url", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => httpClient.get(url: url, params: any(named: "params")))
        .called(1);
  });

  test("should call httpClient with correct params", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => httpClient.get(
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
}
