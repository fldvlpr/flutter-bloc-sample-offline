import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/note_bloc.dart';
import '../../bloc/note_event.dart';
import '../../data/models/note_model.dart';

class AddEditNotePage extends StatefulWidget {
  const AddEditNotePage({super.key});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final note = NoteModel(
                  id: DateTime.now().millisecondsSinceEpoch, // temporary local ID
                  title: _titleController.text,
                  body: _bodyController.text,
                  userId: 1, // dummy user
                );
                // Dispatch the event to save the note
                context.read<NoteBloc>().add(AddNoteEvent(note));
                // Go back to the previous screen
                context.pop();
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}
