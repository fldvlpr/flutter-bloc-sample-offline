import 'package:drift/drift.dart';
import 'package:flutter_bloc_sample_offline/core/database/app_database.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';

class NoteLocalProvider {
  final AppDatabase _db;

  NoteLocalProvider(this._db);

  // Get all notes currently in the local database
  Future<List<NoteModel>> getNotes() async {
    final results = await _db.select(_db.notesTable).get();
    return results
        .map(
          (row) => NoteModel(
            id: row.id,
            title: row.title,
            body: row.body,
            userId: row.userId,
            isSynced: row.isSynced,
          ),
        )
        .toList();
  }

  // Get ONLY the notes that haven't been synced to the server yet
  Future<List<NoteModel>> getUnsyncedNotes() async {
    final query = _db.select(_db.notesTable)
      ..where((t) => t.isSynced.equals(false));
    final results = await query.get();

    return results
        .map(
          (row) => NoteModel(
            id: row.id,
            title: row.title,
            body: row.body,
            userId: row.userId,
            isSynced: row.isSynced,
          ),
        )
        .toList();
  }

  // Insert a single note (used for offline saving)
  Future<void> saveNote(NoteModel note) async {
    await _db
        .into(_db.notesTable)
        .insertOnConflictUpdate(
          NotesTableCompanion.insert(
            id: Value(note.id),
            title: note.title,
            body: note.body,
            userId: note.userId,
            isSynced: Value(note.isSynced),
          ),
        );
  }

  // Clear the table and insert a fresh batch (used after fetching from API)
  Future<void> replaceAllNotes(List<NoteModel> notes) async {
    await _db.transaction(() async {
      await _db.delete(_db.notesTable).go();
      for (var note in notes) {
        await saveNote(note);
      }
    });
  }
}
