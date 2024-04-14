class Note {
  int? id;
  String title;
  String content;
  DateTime modifiedTime;
  int? folderId; // Add folderId field

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
    this.folderId, // Initialize folderId parameter,
  });

  // Convert Note to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'modifiedTime': modifiedTime.toIso8601String(),
      'folderId': folderId, // Add folderId to the map
    };
  }

  // Create a Note from a database Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      modifiedTime: DateTime.parse(map['modifiedTime']),
      folderId: map['folderId'],
    );
  }
}
