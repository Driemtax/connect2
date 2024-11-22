// Holds relations between contact details and tags
class ContactDetailTag {
  int? id;
  int contactDetailId;
  int tagId;

  ContactDetailTag({this.id, required this.contactDetailId, required this.tagId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactDetailId': contactDetailId,
      'tagId': tagId,
    };
  }

  factory ContactDetailTag.fromMap(Map<String, dynamic> map) {
    return ContactDetailTag(
        id: map['id'],
        contactDetailId: map['contactDetailId'],
        tagId: map['tagId']);
  }
}
