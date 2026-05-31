import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/pos_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VeebrewApp(),
    ),
  );
}

class VeebrewApp extends StatelessWidget {
  const VeebrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veebrew POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const POSScreen(),
    );
  }
}
