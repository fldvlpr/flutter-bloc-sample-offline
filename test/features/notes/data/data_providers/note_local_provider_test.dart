import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_bloc_sample_offline/core/database/app_database.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/data_providers/note_local_provider.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';

void main() {
  late AppDatabase database;
  late NoteLocalProvider localProvider;

  setUp(() {
    // Create an in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
    localProvider = NoteLocalProvider(database);
  });

  tearDown(() async {
    await database.close();
  });

  const tNote = NoteModel(id: 1, title: 'Title', body: 'Body', userId: 1, isSynced: false);
  const tSyncedNote = NoteModel(id: 2, title: 'Title 2', body: 'Body 2', userId: 1, isSynced: true);

  group('LocalProvider Tests', () {
    test('saveNote should insert a note into the database', () async {
      await localProvider.saveNote(tNote);

      final notes = await localProvider.getNotes();
      expect(notes.length, 1);
      expect(notes.first.id, 1);
      expect(notes.first.isSynced, false);
    });

    test('getUnsyncedNotes should only return notes where isSynced is false', () async {
      await localProvider.saveNote(tNote);
      await localProvider.saveNote(tSyncedNote);

      final unsynced = await localProvider.getUnsyncedNotes();

      expect(unsynced.length, 1);
      expect(unsynced.first.id, 1);
    });

    test('replaceAllNotes should delete existing and insert new notes', () async {
      await localProvider.saveNote(tNote);
      
      await localProvider.replaceAllNotes([tSyncedNote]);

      final notes = await localProvider.getNotes();
      expect(notes.length, 1);
      expect(notes.first.id, 2); // The new note
    });
  });
}
