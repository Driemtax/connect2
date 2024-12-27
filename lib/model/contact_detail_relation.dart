// Holds relations between contacts
class ContactDetailRelation {
  int? id;
  String relationName;
  int contactDetailId1;
  int contactDetailId2;

  ContactDetailRelation(
      {this.id,
      required this.relationName,
      required this.contactDetailId1,
      required this.contactDetailId2});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relationName': relationName,
      'contactDetailId1': contactDetailId1,
      'contactDetailId2': contactDetailId2,
    };
  }

  factory ContactDetailRelation.fromMap(Map<String, dynamic> map) {
    return ContactDetailRelation(
        id: map['id'],
        relationName: map['relationName'],
        contactDetailId1: map['contactDetailId1'],
        contactDetailId2: map['contactDetailId2']);
  }
}
