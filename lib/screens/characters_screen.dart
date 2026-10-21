import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/character_api.dart';
import 'character_detail_screen.dart';
import 'character_form_dialog.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final _api = CharacterApi();
  final _searchController = TextEditingController();
  List<Character> _characters = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'Todos';
  int _nextLocalId = -1;

  static const _statusFilters = ['Todos', 'Alive', 'Dead', 'Unknown'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
    _loadCharacters();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    _api.close();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCharacters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final characters = await _api.fetchAll();
      if (!mounted) return;
      setState(() {
        _characters = characters;
        _loading = false;
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'La respuesta del catálogo no es válida: ${error.message}';
        _loading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el catálogo. ${_messageFor(error)}';
        _loading = false;
      });
    }
  }

  String _messageFor(Exception error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup')) {
      return 'Revisa tu conexión a internet.';
    }
    if (message.contains('TimeoutException')) {
      return 'La solicitud tardó demasiado. Inténtalo otra vez.';
    }
    return message;
  }

  List<Character> get _visibleCharacters {
    final query = _searchController.text.trim().toLowerCase();
    return _characters.where((character) {
      final matchesQuery =
          query.isEmpty ||
          character.name.toLowerCase().contains(query) ||
          character.species.toLowerCase().contains(query) ||
          character.origin.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == 'Todos' || character.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<void> _createCharacter() async {
    final character = await showDialog<Character>(
      context: context,
      builder: (_) => const CharacterFormDialog(),
    );
    if (character == null || !mounted) return;
    setState(() {
      _characters = [
        Character(
          id: _nextLocalId--,
          name: character.name,
          status: character.status,
          species: character.species,
          gender: character.gender,
          origin: character.origin,
          image: character.image,
        ),
        ..._characters,
      ];
    });
    _showMessage('Personaje agregado al catálogo local.');
  }

  Future<Character?> _editCharacter(Character current) async {
    final edited = await showDialog<Character>(
      context: context,
      builder: (_) => CharacterFormDialog(character: current),
    );
    if (edited == null || !mounted) return null;
    final updated = Character(
      id: current.id,
      name: edited.name,
      status: edited.status,
      species: edited.species,
      gender: edited.gender,
      origin: edited.origin,
      image: edited.image,
    );
    setState(() {
      _characters = _characters
          .map((character) => character.id == current.id ? updated : character)
          .toList();
    });
    _showMessage('Cambios guardados en este dispositivo.');
    return updated;
  }

  Future<bool> _deleteCharacter(Character character) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar personaje'),
        content: Text('¿Quieres eliminar a ${character.name} del catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD95E5E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;
    setState(() {
      _characters.removeWhere((item) => item.id == character.id);
    });
    _showMessage('Personaje eliminado del catálogo local.');
    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _openDetails(Character character) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterDetailScreen(
          character: character,
          onEdit: _editCharacter,
          onDelete: _deleteCharacter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCharacters = _visibleCharacters;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.travel_explore, color: Color(0xFFB8E36B)),
            SizedBox(width: 10),
            Text('Portal de personajes'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar catálogo',
            onPressed: _loading ? null : _loadCharacters,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCharacter,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 18),
                    Text('Abriendo un portal al multiverso...'),
                  ],
                ),
              )
            : _error != null
            ? _ErrorView(message: _error!, onRetry: _loadCharacters)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explora el multiverso',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${_characters.length} personajes · Busca por nombre, especie u origen',
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar personaje...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Limpiar búsqueda',
                                    onPressed: _searchController.clear,
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _statusFilters.map((status) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(_statusLabel(status)),
                                  selected: _statusFilter == status,
                                  onSelected: (_) =>
                                      setState(() => _statusFilter = status),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visibleCharacters.isEmpty
                        ? const Center(
                            child: Text(
                              'No encontramos personajes con esos filtros.',
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = (constraints.maxWidth / 300)
                                  .floor()
                                  .clamp(1, 4);
                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  100,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.82,
                                    ),
                                itemCount: visibleCharacters.length,
                                itemBuilder: (context, index) {
                                  final character = visibleCharacters[index];
                                  return _CharacterCard(
                                    character: character,
                                    onTap: () => _openDetails(character),
                                    onEdit: () => _editCharacter(character),
                                    onDelete: () => _deleteCharacter(character),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'Alive' => 'Vivo',
    'Dead' => 'Muerto',
    'Unknown' => 'Desconocido',
    _ => 'Todos',
  };
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Character character;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CharacterImage(image: character.image),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _StatusBadge(status: character.status),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      tooltip: 'Acciones del personaje',
                      onSelected: (action) {
                        if (action == 'edit') onEdit();
                        if (action == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Editar'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Eliminar'),
                          ),
                        ),
                      ],
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xCC101410),
                        child: Icon(Icons.more_horiz, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${character.species} · ${character.origin}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        'Ver detalles',
                        style: TextStyle(
                          color: Color(0xFFB8E36B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 15,
                        color: Color(0xFFB8E36B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterImage extends StatelessWidget {
  const _CharacterImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return _placeholder();
    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFF252F22),
    child: const Center(
      child: Icon(Icons.person_outline, size: 72, color: Color(0xFFB8E36B)),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Alive' => const Color(0xFFB8E36B),
      'Dead' => const Color(0xFFFF7777),
      _ => Colors.white70,
    };
    final label = switch (status) {
      'Alive' => 'Vivo',
      'Dead' => 'Muerto',
      _ => 'Desconocido',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE6101410),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white54),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
