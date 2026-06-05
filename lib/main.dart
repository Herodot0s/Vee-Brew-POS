import 'dart:ffi';
import 'package:sqlite3/open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/pos_screen.dart';
import 'providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  open.overrideFor(OperatingSystem.android, () {
    try {
      debugPrint('DEBUG: Attempting to load bundled libsqlite3.so...');
      return DynamicLibrary.open('libsqlite3.so');
    } catch (e) {
      debugPrint('DEBUG: Failed to load bundled libsqlite3.so: $e. Falling back to system libsqlite.so...');
      try {
        return DynamicLibrary.open('libsqlite.so');
      } catch (e2) {
        debugPrint('DEBUG: Failed to load system libsqlite.so: $e2');
        rethrow;
      }
    }
  });

  debugPrint('DEBUG: main started');

  final container = ProviderContainer();
  debugPrint('DEBUG: ProviderContainer created');

  try {
    final db = container.read(databaseProvider);
    debugPrint('DEBUG: databaseProvider read');
    
    debugPrint('DEBUG: Seeding database...');
    await db.seedInitialData();
    debugPrint('DEBUG: seedInitialData completed');
  } catch (e, stack) {
    debugPrint('DEBUG: EXCEPTION DURING DB SEEDING: $e');
    debugPrint('DEBUG: STACK TRACE: $stack');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const VeebrewApp()),
  );
  debugPrint('DEBUG: runApp completed');
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
