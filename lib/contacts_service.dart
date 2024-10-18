import 'package:flutter_contacts/flutter_contacts.dart';

// TODO Add more mature features to retrieve contacts
Future<List<Contact>> getContacts() async {
  if (await FlutterContacts.requestPermission()) {
    return await FlutterContacts.getContacts();
  } else {
    return [];
  }
}
