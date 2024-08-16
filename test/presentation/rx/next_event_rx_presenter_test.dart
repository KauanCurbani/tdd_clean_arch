@Timeout(Duration(seconds: 1))

import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/usecases/next_event_loader.dart';
import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/presentation/rx/next_event_rx_presenter.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';



class NextEventLoaderMock with Mock implements NextEventLoader {}

void main() {
  late NextEventLoaderMock loaderMock;
  late NextEventRxPresenter sut;
  late String groupId;

  setUp(() {
    loaderMock = NextEventLoaderMock();
    groupId = Faker().guid.guid();
    sut = NextEventRxPresenter(nextEventLoader: loaderMock.call);

    when(() => loaderMock.call(groupId: any(named: "groupId"))).thenAnswer(
        (_) async => NextEvent(date: DateTime.now(), players: [], groupName: "groupName"));
  });

  test("should get event data", () async {
    await sut.load(groupId: groupId);
    verify(() => loaderMock.call(groupId: groupId)).called(1);
  });

  test("should emit correct events on reload with error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    expectLater(sut.nextEventStream, emitsError(isA<UnexpectedError>()));
    await sut.load(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading with reload on error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    await sut.load(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading on error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    await sut.load(groupId: groupId);
    sut.isLoadingStream.listen(neverCalled);
  });

  test("should emit correct events on isLoading with reload on success", () async {
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(sut.nextEventStream, emits(isA<NextEventViewModel>()));
    await sut.load(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading on success", () async {
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
        (_) async => NextEvent(date: DateTime.now(), players: [], groupName: "groupName"));
    await sut.load(groupId: groupId);
    expectLater(sut.nextEventStream, emits(isA<NextEventViewModel>()));
    sut.isLoadingStream.listen(neverCalled);
  });

  test("should build doubt list sorted by name", () async {
    final players = [
      NextEventPlayer(id: "3", name: "C", isConfirmed: true, confirmationDate: DateTime.now()),
      NextEventPlayer(id: "1", name: "B", isConfirmed: true),
      NextEventPlayer(id: "4", name: "D", isConfirmed: true),
      NextEventPlayer(id: "2", name: "A", isConfirmed: true),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.doubt.length, 3);
      expect(event.doubt[0].name, "A");
      expect(event.doubt[1].name, "B");
      expect(event.doubt[2].name, "D");
    });

    await sut.load(groupId: groupId);
  });

  test("should map doubt player", () async {
    final players = [
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: true,
        position: "position",
        photo: "photo",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.doubt.length, 1);
      expect(event.doubt[0].name, "B");
      expect(event.doubt[0].initials, "B");
      expect(event.doubt[0].position, "position");
      expect(event.doubt[0].photo, "photo");
      expect(event.doubt[0].isConfirmed, true);
    });

    await sut.load(groupId: groupId);
  });

  test("should build out list sorted by confirmationDate", () async {
    final players = [
      NextEventPlayer(
          id: "3", name: "C", isConfirmed: false, confirmationDate: DateTime(2024, 01, 01, 10)),
      NextEventPlayer(
          id: "1", name: "B", isConfirmed: false, confirmationDate: DateTime(2022, 01, 01, 10)),
      NextEventPlayer(
          id: "4", name: "D", isConfirmed: false, confirmationDate: DateTime(2025, 01, 01, 10)),
      NextEventPlayer(
          id: "2", name: "A", isConfirmed: false, confirmationDate: DateTime(2023, 01, 01, 10)),
      NextEventPlayer(
          id: "5", name: "E", isConfirmed: true, confirmationDate: DateTime(2023, 01, 01, 10)),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.out.length, 4);
      expect(event.out[0].name, "B");
      expect(event.out[1].name, "A");
      expect(event.out[2].name, "C");
      expect(event.out[3].name, "D");
    });

    await sut.load(groupId: groupId);
  });

  test("should map out player", () async {
    final players = [
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: false,
        confirmationDate: DateTime.now(),
        position: "position",
        photo: "photo",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.out.length, 1);
      expect(event.out[0].name, "B");
      expect(event.out[0].initials, "B");
      expect(event.out[0].position, "position");
      expect(event.out[0].photo, "photo");
      expect(event.out[0].isConfirmed, false);
    });

    await sut.load(groupId: groupId);
  });

  test("should build out list sorted by confirmationDate", () async {
    final players = [
      NextEventPlayer(
          id: "3", name: "C", isConfirmed: false, confirmationDate: DateTime(2024, 01, 01, 10)),
      NextEventPlayer(
          id: "1", name: "B", isConfirmed: false, confirmationDate: DateTime(2022, 01, 01, 10)),
      NextEventPlayer(
          id: "4", name: "D", isConfirmed: false, confirmationDate: DateTime(2025, 01, 01, 10)),
      NextEventPlayer(
          id: "2", name: "A", isConfirmed: false, confirmationDate: DateTime(2023, 01, 01, 10)),
      NextEventPlayer(
          id: "5", name: "E", isConfirmed: true, confirmationDate: DateTime(2023, 01, 01, 10)),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.out.length, 4);
      expect(event.out[0].name, "B");
      expect(event.out[1].name, "A");
      expect(event.out[2].name, "C");
      expect(event.out[3].name, "D");
    });

    await sut.load(groupId: groupId);
  });

  test("should map out player", () async {
    final players = [
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: false,
        confirmationDate: DateTime.now(),
        position: "position",
        photo: "photo",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.out.length, 1);
      expect(event.out[0].name, "B");
      expect(event.out[0].initials, "B");
      expect(event.out[0].position, "position");
      expect(event.out[0].photo, "photo");
      expect(event.out[0].isConfirmed, false);
    });

    await sut.load(groupId: groupId);
  });

  test("should build goalkeepers list sorted by confirmationDate", () async {
    final players = [
      NextEventPlayer(
        id: "3",
        name: "C",
        isConfirmed: false,
        confirmationDate: DateTime(2024, 01, 01, 10),
        position: "goalkeeper",
      ),
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: false,
      ),
      NextEventPlayer(
        id: "4",
        name: "D",
        isConfirmed: true,
        confirmationDate: DateTime(2025, 01, 01, 10),
      ),
      NextEventPlayer(
        id: "2",
        name: "A",
        isConfirmed: true,
        confirmationDate: DateTime(2023, 01, 01, 10),
        position: "defender",
      ),
      NextEventPlayer(
        id: "5",
        name: "E",
        isConfirmed: true,
        confirmationDate: DateTime(2023, 01, 01, 10),
        position: "goalkeeper",
      ),
      NextEventPlayer(
        id: "6",
        name: "F",
        isConfirmed: true,
        confirmationDate: DateTime(2023, 01, 01, 12),
        position: "goalkeeper",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.goalkeepers.length, 2);
      expect(event.goalkeepers[0].name, "E");
      expect(event.goalkeepers[1].name, "F");
    });

    await sut.load(groupId: groupId);
  });

  test("should map goalkeeper player", () async {
    final players = [
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: true,
        confirmationDate: DateTime.now(),
        position: "goalkeeper",
        photo: "photo",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.goalkeepers.length, 1);
      expect(event.goalkeepers[0].name, "B");
      expect(event.goalkeepers[0].initials, "B");
      expect(event.goalkeepers[0].position, "goalkeeper");
      expect(event.goalkeepers[0].photo, "photo");
      expect(event.goalkeepers[0].isConfirmed, true);
    });

    await sut.load(groupId: groupId);
  });

  test("should build players list sorted by confirmationDate", () async {
    final players = [
      NextEventPlayer(
        id: "3",
        name: "C",
        isConfirmed: false,
        confirmationDate: DateTime(2024, 01, 01, 10),
        position: "goalkeeper",
      ),
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: true,
      ),
      NextEventPlayer(
        id: "4",
        name: "D",
        isConfirmed: true,
        confirmationDate: DateTime(2025, 01, 01, 10),
      ),
      NextEventPlayer(
        id: "2",
        name: "A",
        isConfirmed: true,
        confirmationDate: DateTime(2023, 01, 01, 10),
        position: "defender",
      ),
      NextEventPlayer(
        id: "5",
        name: "E",
        isConfirmed: true,
        confirmationDate: DateTime(2023, 01, 01, 10),
        position: "goalkeeper",
      ),
      NextEventPlayer(
        id: "6",
        name: "F",
        isConfirmed: true,
        confirmationDate: DateTime(2023, 01, 01, 12),
        position: "goalkeeper",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.players.length, 2);
      expect(event.players[0].name, "A");
      expect(event.players[1].name, "D");
    });

    await sut.load(groupId: groupId);
  });

  test("should map player", () async {
    final players = [
      NextEventPlayer(
        id: "1",
        name: "B",
        isConfirmed: true,
        confirmationDate: DateTime.now(),
        position: "position",
        photo: "photo",
      ),
    ];
    when(() => loaderMock.call(groupId: groupId)).thenAnswer(
      (_) async => NextEvent(date: DateTime.now(), players: players, groupName: "groupName"),
    );

    sut.nextEventStream.listen((event) {
      expect(event.players.length, 1);
      expect(event.players[0].name, "B");
      expect(event.players[0].initials, "B");
      expect(event.players[0].position, "position");
      expect(event.players[0].photo, "photo");
      expect(event.players[0].isConfirmed, true);
    });

    await sut.load(groupId: groupId);
  });
}
