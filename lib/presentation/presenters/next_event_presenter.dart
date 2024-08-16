abstract class NextEventPresenter {
  Future<void> load({required String groupId, bool isReload = false});
  Stream<NextEventViewModel> get nextEventStream;
  Stream<bool> get isLoadingStream;
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
  final String initials;
  final String? position;
  final String? photo;
  final bool? isConfirmed;

  const NextEventPlayerViewModel({
    required this.name,
    this.position,
    required this.initials,
    this.photo,
    this.isConfirmed,
  });
}
