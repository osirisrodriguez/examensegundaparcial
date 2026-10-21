import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/main.dart';
import 'package:rick_and_morty_catalog/models/character.dart';
import 'package:rick_and_morty_catalog/screens/login_screen.dart';

void main() {
  test('parses character data from the public API response', () {
    final character = Character.fromJson({
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)'},
      'image': 'https://example.com/rick.png',
    });

    expect(character.id, 1);
    expect(character.name, 'Rick Sanchez');
    expect(character.origin, 'Earth (C-137)');
  });

  testWidgets('login form requires both fields', (tester) async {
    await tester.pumpWidget(const RickAndMortyApp());

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Ingresa tu usuario.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('login compares submitted credentials', (tester) async {
    var authenticated = false;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(onAuthenticated: () => authenticated = true),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    expect(authenticated, isFalse);
    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    expect(authenticated, isTrue);
  });
}
