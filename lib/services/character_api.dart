import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character.dart';

class CharacterApi {
  CharacterApi({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _initialUri = Uri.parse(
    'https://rickandmortyapi.com/api/character',
  );

  final http.Client _client;

  Future<List<Character>> fetchAll() async {
    final characters = <Character>[];
    Uri? next = _initialUri;

    while (next != null) {
      final response = await _client
          .get(next)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception(
          'La API respondió con el código ${response.statusCode}.',
        );
      }

      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! Map<String, dynamic> ||
          payload['results'] is! List<dynamic>) {
        throw const FormatException('La respuesta de la API no es válida.');
      }

      final results = payload['results'] as List<dynamic>;
      for (final item in results) {
        if (item is Map<String, dynamic>) {
          characters.add(Character.fromJson(item));
        } else {
          throw const FormatException('La API devolvió un personaje inválido.');
        }
      }

      final info = payload['info'];
      final nextPage = info is Map<String, dynamic> ? info['next'] : null;
      next = nextPage is String && nextPage.isNotEmpty
          ? Uri.tryParse(nextPage)
          : null;
      if (nextPage is String && next == null) {
        throw const FormatException(
          'La API devolvió un enlace de página inválido.',
        );
      }
    }
    return characters;
  }

  void close() => _client.close();
}
