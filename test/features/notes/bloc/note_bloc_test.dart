import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_event.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_state.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/repositories/note_repository.dart';

class MockNoteRepository extends Mock implements NoteRepository {}
class FakeNoteModel extends Fake implements NoteModel {}

void main() {
  late NoteBloc noteBloc;
  late MockNoteRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeNoteModel());
  });

  setUp(() {
    mockRepository = MockNoteRepository();
    noteBloc = NoteBloc(mockRepository);
  });

  tearDown(() {
    noteBloc.close();
  });

  const tNote = NoteModel(id: 1, title: 'Test', body: 'Body', userId: 1);

  group('NoteBloc Tests', () {
    test('initial state should be NoteInitial', () {
      expect(noteBloc.state, equals(NoteInitial()));
    });

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NoteLoaded] when LoadNotesEvent is added and success',
      build: () {
        when(() => mockRepository.getNotes()).thenAnswer((_) async => [tNote]);
        return noteBloc;
      },
      act: (bloc) => bloc.add(LoadNotesEvent()),
      expect: () => [
        NoteLoading(),
        const NoteLoaded([tNote]),
      ],
      verify: (_) {
        verify(() => mockRepository.getNotes()).called(1);
      },
    );

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NoteError] when LoadNotesEvent fails',
      build: () {
        when(() => mockRepository.getNotes()).thenThrow(Exception('Failed'));
        return noteBloc;
      },
      act: (bloc) => bloc.add(LoadNotesEvent()),
      expect: () => [
        NoteLoading(),
        isA<NoteError>(),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits [NoteLoading, NoteLoaded] when AddNoteEvent is added (triggers reload)',
      build: () {
        when(() => mockRepository.addNote(any())).thenAnswer((_) async => {});
        when(() => mockRepository.getNotes()).thenAnswer((_) async => [tNote]);
        return noteBloc;
      },
      act: (bloc) => bloc.add(const AddNoteEvent(tNote)),
      expect: () => [
        NoteLoading(),
        const NoteLoaded([tNote]),
      ],
      verify: (_) {
        verify(() => mockRepository.addNote(tNote)).called(1);
        verify(() => mockRepository.getNotes()).called(1);
      },
    );
  });
}
