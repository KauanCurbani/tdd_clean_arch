import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/components/player_photo.dart';
import 'package:advanced_flutter/ui/components/player_position.dart';
import 'package:advanced_flutter/ui/components/player_status.dart';
import 'package:flutter/material.dart';

final class NextEventPage extends StatefulWidget {
  final NextEventPresenter presenter;
  final String groupId;
  const NextEventPage({super.key, required this.presenter, required this.groupId});

  @override
  State<NextEventPage> createState() => _NextEventPageState();
}

class _NextEventPageState extends State<NextEventPage> {
  @override
  void initState() {
    super.initState();
    widget.presenter.load(widget.groupId);

    widget.presenter.isLoadingStream.listen((isLoading) => isLoading ? showLoading() : hideLoading());
  }

  void showLoading() {
    showDialog(
      context: context,
      builder: (context) => const CircularProgressIndicator(),
    );
  }

  void hideLoading() {
    Navigator.of(context).maybePop();
  }

  Widget buildErrorMessage() => Column(
        children: [
          const Text("Algo errado aconteceu! Tente novamente."),
          ElevatedButton(
              onPressed: () => widget.presenter.load(widget.groupId, isReload: true), child: const Text("Recarregar"))
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) return buildErrorMessage();

          final viewModel = snapshot.data!;
          List<NextEventPlayerViewModel> goalkeepers = viewModel.goalkeepers;
          List<NextEventPlayerViewModel> players = viewModel.players;
          List<NextEventPlayerViewModel> out = viewModel.out;
          List<NextEventPlayerViewModel> doubt = viewModel.doubt;

          return RefreshIndicator(
            onRefresh: () async => widget.presenter.load(widget.groupId, isReload: true),
            child: ListView(
              children: [
                if (goalkeepers.isNotEmpty) ListSection(title: "DENTRO - GOLEIROS", items: viewModel.goalkeepers),
                if (players.isNotEmpty) ListSection(title: "DENTRO - JOGADORES", items: viewModel.players),
                if (out.isNotEmpty) ListSection(title: "FORA", items: viewModel.out),
                if (doubt.isNotEmpty) ListSection(title: "DÚVIDA", items: viewModel.doubt),
              ],
            ),
          );
        },
      ),
    );
  }
}

final class ListSection extends StatelessWidget {
  final String title;
  final List<NextEventPlayerViewModel> items;
  const ListSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(items.length.toString()),
        ...items.map((player) => Player(player: player)),
      ],
    );
  }
}

class Player extends StatelessWidget {
  final NextEventPlayerViewModel player;
  const Player({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PlayerPhoto(initials: player.initials, photo: player.photo),
        Text(player.name),
        PlayerPosition(position: player.position),
        PlayerStatus(isConfirmed: player.isConfirmed),
      ],
    );
  }
}
