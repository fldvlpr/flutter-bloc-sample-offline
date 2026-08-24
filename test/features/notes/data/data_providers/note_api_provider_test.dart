import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/data_providers/note_api_provider.dart';
import 'package:flutter_bloc_sample_offline/features/notes/data/models/note_model.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}

void main() {
  late NoteApiProvider apiProvider;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiProvider = NoteApiProvider(mockHttpClient);
  });

  group('fetchNotes', () {
    const tUrl = 'https://dummyjson.com/posts';

    test('should return List<NoteModel> when status code is 200 (Success)', () async {
      final successResponse = json.encode({
        "posts": [
          {"id": 1, "title": "Test 1", "body": "Body 1", "userId": 1}
        ]
      });
      when(() => mockHttpClient.get(Uri.parse(tUrl)))
          .thenAnswer((_) async => http.Response(successResponse, 200));

      final result = await apiProvider.fetchNotes();

      expect(result, isA<List<NoteModel>>());
      expect(result.length, 1);
      expect(result.first.title, 'Test 1');
      verify(() => mockHttpClient.get(Uri.parse(tUrl))).called(1);
    });

    test('should throw Exception when status code is not 200 (Failure)', () async {
      when(() => mockHttpClient.get(Uri.parse(tUrl)))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      final call = apiProvider.fetchNotes;

      expect(() => call(), throwsException);
    });
  });

  group('createNote', () {
    const tUrl = 'https://dummyjson.com/posts/add';
    const tNote = NoteModel(id: 0, title: 'Title', body: 'Body', userId: 1);

    test('should return created NoteModel when status is 200/201 (Success)', () async {
      final successResponse = json.encode({
        "id": 101, 
        "title": "Title",
        "body": "Body",
        "userId": 1
      });
      when(() => mockHttpClient.post(
            Uri.parse(tUrl),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(successResponse, 201));

      final result = await apiProvider.createNote(tNote);

      expect(result.id, 101);
      verify(() => mockHttpClient.post(Uri.parse(tUrl), headers: any(named: 'headers'), body: any(named: 'body'))).called(1);
    });

    test('should throw Exception when creation fails (Failure)', () async {
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Bad Request', 400));

      final call = apiProvider.createNote;

      expect(() => call(tNote), throwsException);
    });
  });
}
