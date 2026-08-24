import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object> get props => [];
}

class LoadNotesEvent extends NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final NoteModel note;

  const AddNoteEvent(this.note);

  @override
  List<Object> get props => [note];
}
