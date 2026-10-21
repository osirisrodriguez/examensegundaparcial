import 'package:flutter/material.dart';

import 'screens/characters_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RickAndMortyApp());
}

class RickAndMortyApp extends StatefulWidget {
  const RickAndMortyApp({super.key});

  @override
  State<RickAndMortyApp> createState() => _RickAndMortyAppState();
}

class _RickAndMortyAppState extends State<RickAndMortyApp> {
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB8E36B);
    return MaterialApp(
      title: 'Rick & Morty · Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF191E19),
        ),
        scaffoldBackgroundColor: const Color(0xFF101410),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101410),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B211B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF303830)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF191E19),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF2A322A)),
          ),
        ),
        useMaterial3: true,
      ),
      home: _isAuthenticated
          ? CharactersScreen(
              onLogout: () => setState(() => _isAuthenticated = false),
            )
          : LoginScreen(
              onAuthenticated: () => setState(() => _isAuthenticated = true),
            ),
    );
  }
}
