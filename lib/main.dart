import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/pos_screen.dart';
import 'providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  await db.seedInitialData();

  runApp(
    UncontrolledProviderScope(container: container, child: const VeebrewApp()),
  );
}

class VeebrewApp extends StatelessWidget {
  const VeebrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veebrew POS',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const POSScreen(),
    );
  }
}
