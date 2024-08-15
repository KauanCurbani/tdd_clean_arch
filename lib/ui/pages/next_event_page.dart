import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/components/player_position.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text("Erro ao carregar os dados");
          }

          final viewModel = snapshot.data!;

          return ListView(
            children: [
              if (viewModel.goalkeepers.isNotEmpty)
                ListSection(title: "DENTRO - GOLEIROS", items: viewModel.goalkeepers),
              if (viewModel.players.isNotEmpty) ListSection(title: "DENTRO - JOGADORES", items: viewModel.players),
              if (viewModel.out.isNotEmpty) ListSection(title: "FORA", items: viewModel.out),
              if (viewModel.doubt.isNotEmpty) ListSection(title: "DÚVIDA", items: viewModel.doubt),
            ],
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
          Text(player.name),
          PlayerPosition(position: player.position),
        ],
    );
  }
}
