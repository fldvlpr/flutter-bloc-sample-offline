import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/repositories/note_repository.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository _repository;

  NoteBloc(this._repository) : super(NoteInitial()) {
    // When the UI asks to load notes
    on<LoadNotesEvent>((event, emit) async {
      emit(NoteLoading());
      try {
        final notes = await _repository.getNotes();
        emit(NoteLoaded(notes));
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    });

    // When the UI asks to add a note
    on<AddNoteEvent>((event, emit) async {
      try {
        await _repository.addNote(event.note);
        // After adding, we trigger the load event again to refresh the list
        add(LoadNotesEvent());
      } catch (e) {
        emit(NoteError(e.toString()));
      }
    });
  }
}
