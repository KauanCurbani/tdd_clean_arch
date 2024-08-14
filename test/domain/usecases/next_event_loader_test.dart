import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/repositories/load_next_event_repository.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'next_event_loader_test.mocks.dart';

class NextEventLoader {
  final LoadNextEventRepository repository;

  NextEventLoader({required this.repository});

  Future<NextEvent> call({required String groupId}) async {
    return await repository.loadNextEvent(groupId: groupId);
  }
}

@GenerateMocks([LoadNextEventRepository])
void main() {
  late final LoadNextEventRepository repo;
  late final NextEventLoader sut;
  late final String groupId;

  final NextEvent defaultEvent = NextEvent(
    groupName: "Group Name",
    date: DateTime.now(),
    players: [
      NextEventPlayer(id: "1", name: "Player 1", isConfirmed: true),
      NextEventPlayer(id: "2", name: "Player 2", isConfirmed: false),
    ],
  );

  setUp(() {
    repo = MockLoadNextEventRepository();
    sut = NextEventLoader(repository: repo);
    groupId = Faker().guid.guid();
    when(repo.loadNextEvent(groupId: groupId))
        .thenAnswer((_) async => defaultEvent);
  });

  test("should load event data from a repository", () async {
    await sut(groupId: groupId);
    verify(repo.loadNextEvent(groupId: groupId)).called(1);
  });

  test("should return event data on success", () async {
    final event = await sut(groupId: groupId);

    expect(event, isA<NextEvent>());
    expect(event.date, isA<DateTime>());
    expect(event.groupName, isA<String>());
    expect(event.players, isA<List<NextEventPlayer>>());
    expect(event.groupName, defaultEvent.groupName);
    expect(event.date, defaultEvent.date);
    expect(event.players.length, defaultEvent.players.length);

    expect(event.players[0].id, defaultEvent.players[0].id);
    expect(event.players[0].name, defaultEvent.players[0].name);
    expect(event.players[0].isConfirmed, defaultEvent.players[0].isConfirmed);
    expect(event.players[0].initials, isNotEmpty);
  });
}
