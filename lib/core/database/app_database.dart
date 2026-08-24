import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 1. Define the SQL Table schema
class NotesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  IntColumn get userId => integer()();
  // If false, it means we created/edited it offline and need to sync it later
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))(); 
}

// 2. Define the Database and link the table
@DriftDatabase(tables: [NotesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Added for testing with an in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

// 3. Open connection securely for Flutter
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'notes_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
