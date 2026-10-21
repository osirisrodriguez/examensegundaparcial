import 'package:flutter/material.dart';

import '../models/character.dart';

class CharacterFormDialog extends StatefulWidget {
  const CharacterFormDialog({super.key, this.character});

  final Character? character;

  @override
  State<CharacterFormDialog> createState() => _CharacterFormDialogState();
}

class _CharacterFormDialogState extends State<CharacterFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _originController;
  late final TextEditingController _imageController;
  late final TextEditingController _genderController;
  late String _status;

  static const _statuses = ['Alive', 'Dead', 'Unknown'];
  static const _genders = ['Female', 'Male', 'Genderless', 'Unknown'];

  @override
  void initState() {
    super.initState();
    final character = widget.character;
    _nameController = TextEditingController(text: character?.name);
    _speciesController = TextEditingController(text: character?.species);
    _originController = TextEditingController(text: character?.origin);
    _imageController = TextEditingController(text: character?.image);
    _genderController = TextEditingController(
      text: _genders.contains(character?.gender)
          ? character?.gender
          : 'Unknown',
    );
    _status = _statuses.contains(character?.status)
        ? character!.status
        : 'Unknown';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _originController.dispose();
    _imageController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Este campo es obligatorio.'
      : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final current = widget.character;
    Navigator.of(context).pop(
      Character(
        id: current?.id ?? -1,
        name: _nameController.text.trim(),
        status: _status,
        species: _speciesController.text.trim(),
        gender: _genderController.text.trim(),
        origin: _originController.text.trim(),
        image: _imageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.character != null;
    return AlertDialog(
      title: Text(editing ? 'Editar personaje' : 'Nuevo personaje'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_nameController, 'Nombre', validator: _required),
                const SizedBox(height: 12),
                _field(_speciesController, 'Especie', validator: _required),
                const SizedBox(height: 12),
                _field(_originController, 'Origen', validator: _required),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: _statuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'Unknown'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _genderController.text,
                  decoration: const InputDecoration(labelText: 'Género'),
                  items: _genders
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      _genderController.text = value ?? 'Unknown',
                ),
                const SizedBox(height: 12),
                _field(
                  _imageController,
                  'URL de imagen (opcional)',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null ||
                        !uri.hasAuthority ||
                        !['http', 'https'].contains(uri.scheme)) {
                      return 'Ingresa una URL http o https válida.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
