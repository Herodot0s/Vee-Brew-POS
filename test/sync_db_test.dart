import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/database/drift_database.dart';
import 'package:veebrew/services/menu_sync_service.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';

void main() {
  test('Manual Sync from Markdown to local file', () async {
    final file = File('veebrew.sqlite');
    print('Opening database at ${file.absolute.path}');
    final db = AppDatabase(NativeDatabase(file));

    final markdownFile = File('vee-brew-menu.md');
    if (!await markdownFile.exists()) {
      print('Markdown file not found');
      return;
    }

    final content = await markdownFile.readAsString();
    await MenuSyncService.syncMenuFromMarkdown(db, content);

    final productCount = await db.select(db.products).get();
    print('Sync completed. Products in DB: ${productCount.length}');

    final categoryCount = await db.select(db.categories).get();
    print('Categories in DB: ${categoryCount.length}');

    await db.close();
  });
}
