import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';

void main() {
  group('NoteModel Tests', () {
    test('should correctly parse from JSON', () {
      final jsonMap = {
        "id": 1,
        "title": "Test Note",
        "body": "This is a body",
        "userId": 9
      };

      final result = NoteModel.fromJson(jsonMap);

      expect(result.id, 1);
      expect(result.title, "Test Note");
      expect(result.userId, 9);
      expect(result.isSynced, true); 
    });

    test('should correctly convert to JSON', () {
      const note = NoteModel(
        id: 2,
        title: 'Title',
        body: 'Body',
        userId: 1,
        isSynced: false,
      );

      final result = note.toJson();

      expect(result['id'], 2);
      expect(result['title'], 'Title');
      expect(result['isSynced'], false);
    });
  });
}
