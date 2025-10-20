class NoteItem {
  String id;
  String title;
  String description;
  DateTime dateTime;
  String? imagePath;

  NoteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'imagePath': imagePath,
      };

  factory NoteItem.fromJson(Map<String, dynamic> j) => NoteItem(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        dateTime: DateTime.parse(j['dateTime']),
        imagePath: j['imagePath'],
      );
}
