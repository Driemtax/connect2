class Tag {
  int? id;
  String name;

  Tag({this.id, required this.name});

  Map<String, dynamic> toMap(Tag contactTag) {
    return {
      'id': contactTag.id,
      'name': contactTag.name,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(id: map['id'], name: map['name']);
  }
}
