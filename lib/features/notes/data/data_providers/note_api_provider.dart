import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';

class NoteApiProvider {
  static const String _baseUrl = 'https://dummyjson.com/posts';
  final http.Client _client;

  NoteApiProvider(this._client);

  // Fetch all notes from the remote server
  Future<List<NoteModel>> fetchNotes() async {
    final response = await _client.get(Uri.parse(_baseUrl));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List posts = data['posts'];
      return posts.map((json) => NoteModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notes from API');
    }
  }

  // Push a new note to the remote server
  Future<NoteModel> createNote(NoteModel note) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': note.title,
        'body': note.body,
        'userId': note.userId,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return NoteModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create note on API');
    }
  }
}
