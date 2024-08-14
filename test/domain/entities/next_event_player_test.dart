import 'package:flutter_test/flutter_test.dart';

class NextEventPlayer {
  final String id;
  final String name;
  final String? photo;
  final String? position;
  final bool isConfirmed;
  final DateTime? confirmationDate;
  final String initials;

  NextEventPlayer._({
    required this.id,
    required this.name,
    required this.isConfirmed,
    required this.initials,
    this.photo,
    this.position,
    this.confirmationDate,
  });

  factory NextEventPlayer({
    required String id,
    required String name,
    required bool isConfirmed,
    String? photo,
    String? position,
    DateTime? confirmationDate,
  }) {
    return NextEventPlayer._(
      id: id,
      name: name,
      isConfirmed: isConfirmed,
      photo: photo,
      position: position,
      confirmationDate: confirmationDate,
      initials: _getInitials(name),
    );
  }

  static String _getInitials(String name) {
    final names = name.split(" ");
    final firstChar = names.first[0];
    final lastChar = names.last[names.length == 1 ? 1 : 0];
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

  test("should return the first letters of the first name", () {
    expect(initialsOf("Kauan"), "Ka");
  });
}
