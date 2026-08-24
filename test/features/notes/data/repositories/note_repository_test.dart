import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/data_providers/note_api_provider.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/data_providers/note_local_provider.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/repositories/note_repository.dart';

class MockNoteApiProvider extends Mock implements NoteApiProvider {}
class MockNoteLocalProvider extends Mock implements NoteLocalProvider {}
class MockConnectivity extends Mock implements Connectivity {}
class FakeNoteModel extends Fake implements NoteModel {}

void main() {
  late NoteRepository repository;
  late MockNoteApiProvider mockApiProvider;
  late MockNoteLocalProvider mockLocalProvider;
  late MockConnectivity mockConnectivity;

  setUpAll(() {
    registerFallbackValue(FakeNoteModel());
  });

  setUp(() {
    mockApiProvider = MockNoteApiProvider();
    mockLocalProvider = MockNoteLocalProvider();
    mockConnectivity = MockConnectivity();
    repository = NoteRepository(mockApiProvider, mockLocalProvider, mockConnectivity);
  });

  const tNote = NoteModel(id: 1, title: 'Title', body: 'Body', userId: 1, isSynced: false);
  const tSyncedNote = NoteModel(id: 1, title: 'Title', body: 'Body', userId: 1, isSynced: true);

  group('getNotes', () {
    test('should return local notes and trigger sync if online', () async {
      when(() => mockLocalProvider.getNotes()).thenAnswer((_) async => [tNote]);
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockLocalProvider.getUnsyncedNotes()).thenAnswer((_) async => []);
      when(() => mockApiProvider.fetchNotes()).thenAnswer((_) async => [tSyncedNote]);
      when(() => mockLocalProvider.replaceAllNotes(any())).thenAnswer((_) async => {});

      final result = await repository.getNotes();

      expect(result, equals([tNote]));
      verify(() => mockLocalProvider.getNotes()).called(1);
      await Future.delayed(const Duration(milliseconds: 100)); 
      verify(() => mockApiProvider.fetchNotes()).called(1);
    });
  });

  group('addNote', () {
    test('should save locally as unsynced when offline', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
      when(() => mockLocalProvider.saveNote(any())).thenAnswer((_) async => {});

      await repository.addNote(tNote);

      verify(() => mockLocalProvider.saveNote(tNote.copyWith(isSynced: false))).called(1);
      verifyNever(() => mockApiProvider.createNote(any()));
    });

    test('should save to API and update local as synced when online', () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockApiProvider.createNote(any())).thenAnswer((_) async => tSyncedNote);
      when(() => mockLocalProvider.saveNote(any())).thenAnswer((_) async => {});

      await repository.addNote(tNote);

      verify(() => mockApiProvider.createNote(tNote)).called(1);
      verify(() => mockLocalProvider.saveNote(tSyncedNote.copyWith(isSynced: true))).called(1);
    });
  });
}
