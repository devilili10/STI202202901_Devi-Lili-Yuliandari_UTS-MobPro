import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note_item.dart';
import '../services/notes_storage.dart';
import 'add_edit_page.dart';
import 'photo_view_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<NoteItem> _notes = [];
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await NotesStorage.loadNotes();
    setState(() {
      _notes.clear();
      _notes.addAll(loaded);
      _loading = false;
    });
  }

  Future<void> _save() async {
    await NotesStorage.saveNotes(_notes);
  }

  void _addOrEdit(NoteItem? existing) async {
    final result = await Navigator.push<NoteItem>(
      context,
      MaterialPageRoute(builder: (_) => AddEditPage(note: existing)),
    );
    if (result != null) {
      setState(() {
        if (existing != null) {
          final i = _notes.indexWhere((n) => n.id == existing.id);
          if (i != -1) _notes[i] = result;
        } else {
          _notes.insert(0, result);
        }
      });
      await _save();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Catatan disimpan')));
    }
  }

  Future<void> _delete(NoteItem note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus catatan'),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm ?? false) {
      setState(() => _notes.removeWhere((n) => n.id == note.id));
      await _save();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Catatan dihapus')));
    }
  }

  Widget _noteCard(NoteItem note) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GestureDetector(
          onTap: () => _addOrEdit(note),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: Row(
              children: [
                if (note.imagePath != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.file(File(note.imagePath!), width: 110, height: 110, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 110,
                    height: 110,
                    alignment: Alignment.center,
                    child: const Icon(Icons.book, color: Colors.grey, size: 40),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(note.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold))),
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'edit') _addOrEdit(note);
                                if (v == 'delete') _delete(note);
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                              ],
                            ),
                          ],
                        ),
                        Text(note.description,
                            maxLines: 3, overflow: TextOverflow.ellipsis),
                        Text('${note.dateTime.toLocal()}'.split('.').first,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _homeTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_notes.isEmpty) {
      return const Center(child: Text('Belum ada catatan. Tekan + untuk menambah.'));
    }
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (_, i) => _noteCard(_notes[i]),
    );
  }

  Widget _galleryTab() {
    final imgs = _notes.where((n) => n.imagePath != null).toList();
    if (imgs.isEmpty) return const Center(child: Text('Belum ada foto di galeri.'));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: imgs.length,
      itemBuilder: (_, i) {
        final note = imgs[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PhotoViewPage(path: note.imagePath!)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(note.imagePath!), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [_homeTab(), Container(), _galleryTab()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Journal'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') {
                setState(() => _notes.clear());
                await _save();
              }
            },
            itemBuilder: (_) => [const PopupMenuItem(value: 'clear', child: Text('Bersihkan Semua'))],
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Galeri'),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: () => _addOrEdit(null), child: const Icon(Icons.add)),
    );
  }
}
