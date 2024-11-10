class Tag {
  int? id;
  String name;

  Tag({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(id: map['id'], name: map['name']);
  }
}
