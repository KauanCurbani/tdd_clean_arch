
import 'package:flutter/material.dart';

final class PlayerStatus extends StatelessWidget {
  final bool? isConfirmed;
  const PlayerStatus({super.key, this.isConfirmed});

  Color getColor() => switch (isConfirmed) {
        true => Colors.teal,
        false => Colors.pink,
        _ => Colors.blueGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: getColor(),
        shape: BoxShape.circle,
      ),
    );
  }
}
