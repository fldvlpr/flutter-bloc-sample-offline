import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_event.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_state.dart';
import 'package:flutter_bloc_sample_offline/features/notes/presentation/pages/add_edit_note_page.dart';

class MockNoteBloc extends MockBloc<NoteEvent, NoteState> implements NoteBloc {}
class FakeAddNoteEvent extends Fake implements AddNoteEvent {}

void main() {
  late MockNoteBloc mockNoteBloc;
  late GoRouter router;

  setUpAll(() {
    registerFallbackValue(FakeAddNoteEvent());
  });

  setUp(() {
    mockNoteBloc = MockNoteBloc();
    when(() => mockNoteBloc.state).thenReturn(NoteInitial());

    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => BlocProvider<NoteBloc>.value(
            value: mockNoteBloc,
            child: const AddEditNotePage(),
          ),
        ),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('should dispatch AddNoteEvent when save button is pressed', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Push to the add page so we have something to pop back to
    router.push('/add');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'New Title');
    await tester.enterText(find.byType(TextField).last, 'New Body');
    await tester.pump();

    await tester.tap(find.text('Save Note'));
    await tester.pumpAndSettle();

    verify(() => mockNoteBloc.add(any(that: isA<AddNoteEvent>()))).called(1);
  });
}
