import 'dart:convert';

import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/infra/api/repositories/load_next_event_http_repo.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late String groupId;
  late Client client;
  late LoadNextEventHttpRepository sut;
  const url = "https://any-url.com/api/v1/groups/:groupId/next-event";
  String jsonResponse = jsonEncode({
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
  });

  setUp(() {
    groupId = Faker().guid.guid();
    client = MockClient();
    sut = LoadNextEventHttpRepository(httpClient: client, url: url);

    when(() => client.get(any(), headers: any(named: "headers")))
        .thenAnswer((_) async => Response(jsonResponse, 200));
  });

  setUpAll(() => {registerFallbackValue(FakeUri())});

  test("should request with correct method", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => client.get(any(), headers: any(named: "headers"))).called(1);
  });

  test("should request with correct url", () async {
    await sut.loadNextEvent(groupId: groupId);
    Uri expectedUri = Uri.parse(url.replaceFirst(":groupId", groupId));
    verify(
      () => client.get(expectedUri, headers: any(named: "headers")),
    ).called(1);
  });

  test("should request with correct headers", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => client.get(any(), headers: {
          "content-type": "application/json",
          "accept": "application/json",
        })).called(1);
  });

  test("should return NextEvent on success", () async {
    final event = await sut.loadNextEvent(groupId: groupId);

    expect(event, isA<NextEvent>());
    expect(event.groupName, "Group Name");
    expect(event.date, isA<DateTime>());
    expect(event.players, isA<List<NextEventPlayer>>());
    expect(event.players.length, 2);

    expect(event.players[0].id, "1");
    expect(event.players[0].name, "Player 1");
    expect(event.players[0].isConfirmed, true);
    expect(event.players[0].confirmationDate, isA<DateTime>());
    expect(event.players[0].photo, "photo");
    expect(event.players[0].position, "position");

    expect(event.players[1].id, "2");
    expect(event.players[1].name, "Player 2");
    expect(event.players[1].isConfirmed, false);
    expect(event.players[1].confirmationDate, isNull);
    expect(event.players[1].photo, isNull);
    expect(event.players[1].position, isNull);
  });


}
