import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;
  late final String initials;

  NextEventPlayer({
    required this.id,
    required this.name,
    required this.isConfirmed,
    this.photo,
    this.position,
    this.confirmationDate,
  }) {
    initials = _getInitials();
  }

  String _getInitials() {
    final names = name.split(" ");
    final firstChar = names.first[0];
    final lastChar = names.last[0];
    return '$firstChar$lastChar';
  }
}

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: "", name: name, isConfirmed: true).initials;

  test("should return the first letter of the first and last names", () {
    expect(initialsOf("John Doe"), "JD");
    expect(initialsOf("Kauan Curbani"), "KC");
    expect(initialsOf("João Paulo da Silva"), "JS");
  });
}
