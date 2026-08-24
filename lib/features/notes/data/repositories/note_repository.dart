import 'package:connectivity_plus/connectivity_plus.dart';
import '../data_providers/note_api_provider.dart';
import '../data_providers/note_local_provider.dart';
import '../models/note_model.dart';

class NoteRepository {
  final NoteApiProvider _apiProvider;
  final NoteLocalProvider _localProvider;
  final Connectivity _connectivity;

  NoteRepository(this._apiProvider, this._localProvider, this._connectivity);

  /// Always returns local notes for instant UI loading, 
  /// but triggers a background sync.
  Future<List<NoteModel>> getNotes() async {
    // Fire and forget sync (don't await it so UI loads instantly)
    _syncNotes(); 
    return await _localProvider.getNotes();
  }

  /// Adds a note. If offline, saves locally as 'unsynced'. 
  /// If online, tries to save to API first.
  Future<void> addNote(NoteModel note) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    
    // We check if it contains 'none' because connectivity_plus now returns a List
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // 🔴 OFFLINE: Save locally and mark for future sync
      await _localProvider.saveNote(note.copyWith(isSynced: false));
    } else {
      // 🟢 ONLINE: Try to push to server first
      try {
        final createdNote = await _apiProvider.createNote(note);
        await _localProvider.saveNote(createdNote.copyWith(isSynced: true));
      } catch (e) {
        // If API fails (e.g. 500 error), fallback to offline save
        await _localProvider.saveNote(note.copyWith(isSynced: false));
      }
    }
  }

  /// Core Sync Logic: Pushes pending local notes, then fetches fresh server notes
  Future<void> _syncNotes() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return;

    // 1. Push unsynced local notes to the server
    final unsyncedNotes = await _localProvider.getUnsyncedNotes();
    for (var note in unsyncedNotes) {
      try {
        final syncedNote = await _apiProvider.createNote(note);
        // If successful, update local DB to mark as synced
        await _localProvider.saveNote(syncedNote.copyWith(isSynced: true));
      } catch (e) {
        // Skip on error, we'll try again next sync
      }
    }

    // 2. Fetch fresh truth from server and overwrite local DB
    try {
      final remoteNotes = await _apiProvider.fetchNotes();
      // Keep local unsynced notes, only overwrite the synced ones
      // In a real app, you'd do a more complex merge, but replaceAll is standard for simple lists
      await _localProvider.replaceAllNotes(remoteNotes); 
    } catch (e) {
      // Ignore fetch errors in background
    }
  }
}
