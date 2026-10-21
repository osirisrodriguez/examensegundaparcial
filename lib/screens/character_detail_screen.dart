import 'package:flutter/material.dart';

import '../models/character.dart';

class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({
    super.key,
    required this.character,
    required this.onEdit,
    required this.onDelete,
  });

  final Character character;
  final Future<Character?> Function(Character) onEdit;
  final Future<bool> Function(Character) onDelete;

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late Character _character = widget.character;

  Future<void> _edit() async {
    final updated = await widget.onEdit(_character);
    if (updated != null && mounted) setState(() => _character = updated);
  }

  Future<void> _delete() async {
    final deleted = await widget.onDelete(_character);
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final character = _character;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del personaje'),
        actions: [
          IconButton(
            tooltip: 'Editar personaje',
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar personaje',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: character.image.isEmpty
                        ? const ColoredBox(
                            color: Color(0xFF252F22),
                            child: Icon(
                              Icons.person_outline,
                              size: 100,
                              color: Color(0xFFB8E36B),
                            ),
                          )
                        : Image.network(
                            character.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: Color(0xFF252F22),
                              child: Icon(
                                Icons.person_outline,
                                size: 100,
                                color: Color(0xFFB8E36B),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          avatar: Icon(
                            Icons.circle,
                            size: 10,
                            color: _statusColor(character.status),
                          ),
                          label: Text(_statusName(character.status)),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          character.name,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 22),
                        _DetailRow(label: 'Especie', value: character.species),
                        _DetailRow(label: 'Género', value: character.gender),
                        _DetailRow(
                          label: 'Estado',
                          value: _statusName(character.status),
                        ),
                        _DetailRow(label: 'Origen', value: character.origin),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusName(String status) => switch (status) {
    'Alive' => 'Vivo',
    'Dead' => 'Muerto',
    _ => 'Desconocido',
  };

  Color _statusColor(String status) => switch (status) {
    'Alive' => const Color(0xFFB8E36B),
    'Dead' => const Color(0xFFFF7777),
    _ => Colors.white70,
  };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Sin información' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
