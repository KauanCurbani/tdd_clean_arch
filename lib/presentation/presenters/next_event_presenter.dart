abstract class NextEventPresenter {
  void load(String groupId);
  Stream<NextEventViewModel> get nextEventStream;
}

final class NextEventViewModel {
  final List<NextEventPlayerViewModel> goalkeepers;
  final List<NextEventPlayerViewModel> players;
  final List<NextEventPlayerViewModel> out;
  final List<NextEventPlayerViewModel> doubt;

  const NextEventViewModel({
    this.goalkeepers = const [],
    this.players = const [],
    this.out = const [],
    this.doubt = const [],
  });
}

final class NextEventPlayerViewModel {
  final String name;

  const NextEventPlayerViewModel({
    required this.name,
  });
}