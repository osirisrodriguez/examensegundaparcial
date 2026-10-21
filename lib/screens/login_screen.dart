import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final Map<String, String> _users = {'admin': '1234'};
  bool _isRegistering = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_isRegistering) {
      if (_users.containsKey(username)) {
        _showMessage('Ese usuario ya está registrado.');
        return;
      }
      _users[username] = password;
      widget.onAuthenticated();
      return;
    }

    if (_users[username] == password) {
      widget.onAuthenticated();
    } else {
      _showMessage('Usuario o contraseña incorrectos.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 36 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 104,
                          decoration: BoxDecoration(
                            color: const Color(0xFF252F22),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            size: 56,
                            color: Color(0xFFB8E36B),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _isRegistering
                              ? 'Únete al multiverso'
                              : 'Wubba Lubba Dub Dub!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegistering
                              ? 'Crea una cuenta para explorar personajes.'
                              : 'Entra al portal y explora el multiverso.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu usuario.';
                            }
                            if (_isRegistering && value.trim().length < 3) {
                              return 'El usuario debe tener al menos 3 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña.';
                            }
                            if (_isRegistering && value.length < 4) {
                              return 'Usa al menos 4 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: const Color(0xFFB8E36B),
                            foregroundColor: const Color(0xFF17200F),
                          ),
                          child: Text(
                            _isRegistering ? 'Crear cuenta' : 'Ingresar',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isRegistering = !_isRegistering;
                            _formKey.currentState?.reset();
                          }),
                          child: Text(
                            _isRegistering
                                ? 'Ya tengo una cuenta · Iniciar sesión'
                                : '¿Nuevo por aquí? Crear cuenta',
                          ),
                        ),
                        if (!_isRegistering) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252F22),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Cuenta de demostración: admin  ·  Contraseña: 1234',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
