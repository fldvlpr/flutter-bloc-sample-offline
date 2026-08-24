import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_event.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_state.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';
import 'package:flutter_bloc_sample_offline/features/notes/presentation/pages/notes_page.dart';

class MockNoteBloc extends MockBloc<NoteEvent, NoteState> implements NoteBloc {}

void main() {
  late MockNoteBloc mockNoteBloc;

  setUp(() {
    mockNoteBloc = MockNoteBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<NoteBloc>.value(
        value: mockNoteBloc,
        child: const NotesPage(),
      ),
    );
  }

  group('NotesPage Tests', () {
    testWidgets('should show text when state is NoteLoaded but empty', (tester) async {
      when(() => mockNoteBloc.state).thenReturn(const NoteLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No notes yet! Tap + to add.'), findsOneWidget);
    });

    testWidgets('should show list of notes when state is NoteLoaded with data', (tester) async {
      const tNote = NoteModel(id: 1, title: 'Test Title', body: 'Test Body', userId: 1, isSynced: true);
      when(() => mockNoteBloc.state).thenReturn(const NoteLoaded([tNote]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('should show cloud_off icon when note is not synced', (tester) async {
      const tNote = NoteModel(id: 1, title: 'Test Title', body: 'Test Body', userId: 1, isSynced: false);
      when(() => mockNoteBloc.state).thenReturn(const NoteLoaded([tNote]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });
  });
}
