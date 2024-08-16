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
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: getColor().withAlpha(50),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: getColor(),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
