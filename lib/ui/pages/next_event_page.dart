import 'package:advanced_flutter/presentation/presenters/next_event_presenter.dart';
import 'package:advanced_flutter/ui/components/player_photo.dart';
import 'package:advanced_flutter/ui/components/player_position.dart';
import 'package:advanced_flutter/ui/components/player_status.dart';
import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
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
    widget.presenter.load(groupId: widget.groupId);

    widget.presenter.isLoadingStream
        .listen((isLoading) => isLoading ? showLoading() : hideLoading());
  }

  @override
  void didUpdateWidget(covariant NextEventPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.presenter.load(groupId: widget.groupId, isReload: true);
  }

  void showLoading() {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoading() {
    Navigator.of(context).maybePop();
  }

  Widget buildErrorMessage() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Algo errado aconteceu! Tente novamente.", style: context.textStyles.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => widget.presenter.load(groupId: widget.groupId, isReload: true),
                child: Text("Recarregar", style: context.textStyles.labelLarge)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Próximo Jogo")),
      body: StreamBuilder<NextEventViewModel>(
        stream: widget.presenter.nextEventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return buildErrorMessage();

          final viewModel = snapshot.data!;
          List<NextEventPlayerViewModel> goalkeepers = viewModel.goalkeepers;
          List<NextEventPlayerViewModel> players = viewModel.players;
          List<NextEventPlayerViewModel> out = viewModel.out;
          List<NextEventPlayerViewModel> doubt = viewModel.doubt;

          return RefreshIndicator(
            onRefresh: () async => widget.presenter.load(groupId: widget.groupId, isReload: true),
            child: ListView(
              children: [
                if (goalkeepers.isNotEmpty)
                  ListSection(title: "DENTRO - GOLEIROS", items: viewModel.goalkeepers),
                if (players.isNotEmpty)
                  ListSection(title: "DENTRO - JOGADORES", items: viewModel.players),
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
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                title,
                style: context.textStyles.titleSmall,
              )),
              Text(
                items.length.toString(),
                style: context.textStyles.titleSmall,
              ),
            ],
          ),
        ),
        const Divider(),
        ...items.map((player) => Player(player: player)).separatedBy(const Divider(
              indent: 82,
            )),
        const Divider(),
      ],
    );
  }
}

class Player extends StatelessWidget {
  final NextEventPlayerViewModel player;
  const Player({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.scheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          PlayerPhoto(initials: player.initials, photo: player.photo),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: context.textStyles.labelLarge,
                ),
                PlayerPosition(position: player.position),
              ],
            ),
          ),
          PlayerStatus(isConfirmed: player.confirmationDate != null ? player.isConfirmed : null),
        ],
      ),
    );
  }
}
