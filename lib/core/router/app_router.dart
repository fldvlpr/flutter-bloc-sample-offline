import 'package:flutter_bloc_sample_offline/features/notes/presentation/pages/add_edit_note_page.dart';
import 'package:flutter_bloc_sample_offline/features/notes/presentation/pages/notes_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample_offline/core/di/injection.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/bloc/note_event.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/repositories/note_repository.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (context) => NoteBloc(sl<NoteRepository>())..add(LoadNotesEvent()),
          child: child,
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const NotesPage()),
        GoRoute(path: '/add', builder: (context, state) => const AddEditNotePage()),
      ],
    ),
  ],
);
