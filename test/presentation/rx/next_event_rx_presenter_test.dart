@Timeout(Duration(seconds: 1))

import 'package:advanced_flutter/domain/entities/errors.dart';
import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/domain/usecases/next_event_loader.dart';
import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:dartx/dartx_io.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

final class NextEventRxPresenter {
  final Future<NextEvent> Function({required String groupId}) nextEventLoader;
  final nextEventSubject = BehaviorSubject<NextEventViewModel>();
  final isLoadingSubject = BehaviorSubject<bool>();

  NextEventRxPresenter({required this.nextEventLoader});

  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;
  Stream<bool> get isLoadingStream => isLoadingSubject.stream;

  Future<void> loadNextEvent({required String groupId, bool isReload = false}) async {
    try {
      if (isReload) isLoadingSubject.add(true);
      final response = await nextEventLoader(groupId: groupId);
      nextEventSubject.add(_mapEvent(response));
    } catch (e) {
      nextEventSubject.addError(e);
    } finally {
      if (isReload) isLoadingSubject.add(false);
    }
  }

  NextEventViewModel _mapEvent(NextEvent event) => NextEventViewModel(
      doubt: event.players
          .where((player) => player.confirmationDate == null)
          .sortedBy((p) => p.name)
          .map((player) => _mapPlayer(player))
          .toList());

  NextEventPlayerViewModel _mapPlayer(NextEventPlayer player) => NextEventPlayerViewModel(
        name: player.name,
        initials: player.name[0],
        position: player.position,
        photo: player.photo,
        isConfirmed: player.isConfirmed,
      );
}

class NextEventLoaderMock with Mock implements NextEventLoader {}

void main() {
  late NextEventLoaderMock loaderMock;
  late NextEventRxPresenter sut;
  late String groupId;

  setUp(() {
    loaderMock = NextEventLoaderMock();
    groupId = Faker().guid.guid();
    sut = NextEventRxPresenter(nextEventLoader: loaderMock.call);

    when(() => loaderMock.call(groupId: any(named: "groupId")))
        .thenAnswer((_) async => NextEvent(date: DateTime.now(), players: [], groupName: "groupName"));
  });

  test("should get event data", () async {
    await sut.loadNextEvent(groupId: groupId);
    verify(() => loaderMock.call(groupId: groupId)).called(1);
  });

  test("should emit correct events on reload with error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    expectLater(sut.nextEventStream, emitsError(isA<UnexpectedError>()));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading with reload on error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading on error", () async {
    when(() => loaderMock.call(groupId: groupId)).thenThrow(UnexpectedError());
    await sut.loadNextEvent(groupId: groupId);
    sut.isLoadingStream.listen(neverCalled);
  });

  test("should emit correct events on isLoading with reload on success", () async {
    expectLater(sut.isLoadingStream, emitsInOrder([true, false]));
    expectLater(sut.nextEventStream, emits(isA<NextEventViewModel>()));
    await sut.loadNextEvent(groupId: groupId, isReload: true);
  });

  test("should emit correct events on isLoading on success", () async {
    when(() => loaderMock.call(groupId: groupId))
        .thenAnswer((_) async => NextEvent(date: DateTime.now(), players: [], groupName: "groupName"));
    await sut.loadNextEvent(groupId: groupId);
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

    await sut.loadNextEvent(groupId: groupId);
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

    await sut.loadNextEvent(groupId: groupId);
  });
}
