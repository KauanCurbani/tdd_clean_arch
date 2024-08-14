import 'package:advanced_flutter/domain/entities/next_event_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String initialsOf(String name) =>
      NextEventPlayer(id: "", name: name, isConfirmed: true).initials;

  test("should return the first letter of the first and last names", () {
    expect(initialsOf("John Doe"), "JD");
    expect(initialsOf("Kauan Curbani"), "KC");
    expect(initialsOf("João Paulo da Silva"), "JS");
  });

  test("should return the first letters of the first name", () {
    expect(initialsOf("Kauan"), "KA");
    expect(initialsOf("K"), "K");
  });

  test("should return (-) when name is empty", () {
    expect(initialsOf(""), "-");
  });

  test("should convert the name to uppercase", () {
    expect(initialsOf("kauan curbani"), "KC");
    expect(initialsOf("kauan"), "KA");
    expect(initialsOf("john due"), "JD");
  });

  test("should ignore extra whitespace", () {
    expect(initialsOf("kauan curbani "), "KC");
    expect(initialsOf(" kauan curbani"), "KC");
    expect(initialsOf(" kauan curbani "), "KC");
    expect(initialsOf(" kauan  "), "KA");
    expect(initialsOf(" k  "), "K");
    expect(initialsOf("  "), "-");
  });
}
