import 'package:advanced_flutter/domain/entities/next_event.dart';
import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:dartx/dartx_io.dart';
import 'package:rxdart/rxdart.dart';

final class NextEventRxPresenter implements NextEventPresenter {
  final Future<NextEvent> Function({required String groupId}) nextEventLoader;
  final nextEventSubject = BehaviorSubject<NextEventViewModel>();
  final isLoadingSubject = BehaviorSubject<bool>();

  NextEventRxPresenter({required this.nextEventLoader});

  @override
  Stream<NextEventViewModel> get nextEventStream => nextEventSubject.stream;
  @override
  Stream<bool> get isLoadingStream => isLoadingSubject.stream;

  @override
  Future<void> load({required String groupId, bool isReload = false}) async {
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

  Iterable<NextEventPlayer> _confirmed(List<NextEventPlayer> players) =>
      players.where((player) => player.confirmationDate != null);

  Iterable<NextEventPlayer> _in(List<NextEventPlayer> players) =>
      _confirmed(players).where((player) => player.isConfirmed! == true);

  Iterable<NextEventPlayer> _out(List<NextEventPlayer> players) =>
      _confirmed(players).where((player) => player.isConfirmed! == false);

  Iterable<NextEventPlayer> _goalkeepers(List<NextEventPlayer> players) =>
      _in(players).where((player) => player.position == "goalkeeper");

  Iterable<NextEventPlayer> _players(List<NextEventPlayer> players) =>
      _in(players).where((player) => player.position != "goalkeeper");

  NextEventViewModel _mapEvent(NextEvent event) => NextEventViewModel(
        doubt: event.players
            .where((player) => player.confirmationDate == null)
            .sortedBy((p) => p.name)
            .map((player) => _mapPlayer(player))
            .toList(),
        out: _out(event.players)
            .sortedBy((p) => p.confirmationDate!)
            .map((player) => _mapPlayer(player))
            .toList(),
        goalkeepers: _goalkeepers(event.players)
            .sortedBy((p) => p.confirmationDate!)
            .map((player) => _mapPlayer(player))
            .toList(),
        players: _players(event.players)
            .sortedBy((p) => p.confirmationDate!)
            .map((player) => _mapPlayer(player))
            .toList(),
      );

  NextEventPlayerViewModel _mapPlayer(NextEventPlayer player) => NextEventPlayerViewModel(
        name: player.name,
        initials: player.initials,
        position: player.position,
        photo: player.photo,
        isConfirmed: player.isConfirmed,
        confirmationDate: player.confirmationDate,
      );
}
