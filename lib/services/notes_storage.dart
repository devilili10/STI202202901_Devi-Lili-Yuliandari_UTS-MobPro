import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note_item.dart';

class NotesStorage {
  static const _fileName = 'notes.json';

  static Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<List<NoteItem>> loadNotes() async {
    try {
      final f = await _localFile();
      if (!await f.exists()) return [];
      final s = await f.readAsString();
      final list = json.decode(s) as List<dynamic>;
      return list.map((e) => NoteItem.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveNotes(List<NoteItem> notes) async {
    final f = await _localFile();
    final s = json.encode(notes.map((e) => e.toJson()).toList());
    await f.writeAsString(s);
  }
}
