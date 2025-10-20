import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_item.dart';

class AddEditPage extends StatefulWidget {
  final NoteItem? note;
  const AddEditPage({super.key, this.note});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selected = DateTime.now();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleCtrl.text = widget.note!.title;
      _descCtrl.text = widget.note!.description;
      _selected = widget.note!.dateTime;
      _imagePath = widget.note!.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final appDir = await getApplicationDocumentsDirectory();
    final saved = await File(file.path)
        .copy('${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
    setState(() => _imagePath = saved.path);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _selected = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selected));
    if (t != null)
      setState(() => _selected = DateTime(
          _selected.year, _selected.month, _selected.day, t.hour, t.minute));
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final id = widget.note?.id ?? UniqueKey().toString();
    final n = NoteItem(
      id: id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dateTime: _selected,
      imagePath: _imagePath,
    );
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Tambah Catatan' : 'Edit Catatan'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            if (_imagePath != null)
              Stack(children: [
                Image.file(File(_imagePath!), height: 180, fit: BoxFit.cover),
                Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => setState(() => _imagePath = null))),
              ])
            else
              OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Pilih Foto')),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration:
                  const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.date_range),
                    label: const Text('Tanggal')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: const Text('Waktu')),
              ],
            ),
            const SizedBox(height: 8),
            Text('${_selected.toLocal()}'.split('.').first),
          ],
        ),
      ),
    );
  }
}
