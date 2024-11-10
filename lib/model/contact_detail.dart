// Holds additional information about phone contacts
class ContactDetail {
  // The id inside the database
  int? id;
  // The id of the related phone contact
  String contactId;

  ContactDetail({this.id, required this.contactId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
    };
  }

  factory ContactDetail.fromMap(Map<String, dynamic> map) {
    return ContactDetail(id: map['id'], contactId: map['contactId']);
  }
}
