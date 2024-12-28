import 'dart:async';

import 'package:connect2/services/contacts_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactManager {
  final int contactId;
  Map<String, dynamic> contactData = {};
  Timer? _debounceTimer;

  ContactManager(this.contactId, this.contactData);

  ContactManager.withId(this.contactId) {
    contactData = {};
  }

  // Method will be called on every change
  void updateContactField(String field, dynamic value) {
    contactData[field] = value;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _saveContactToDatabase();
    });
  }

  Future<void> _saveContactToDatabase() async {
    // TODO Update database here
    Contact updatedContact = Contact();
    updatedContact.id = contactId.toString();
    updatedContact.name.first = contactData["name"];
    updatedContact.addresses.first = Address(contactData["residence"]);
    updatedContact.organizations.first = contactData["employer"];

    // Save updated Contact to phone contacts
    saveModifiedContact(updatedContact);
    // await database.update(contactId, contactData);
  }

  Future<void> loadContactFromDatabase() async {
  // Simuliere das Laden von Daten aus der Datenbank
  await Future.delayed(const Duration(seconds: 1)); // Simulates Loading Time for now
  Contact contact = await getContact(contactId.toString());
  contactData = {
    "name": contact.name.first,
    "birthDate": DateTime(1990, 1, 1),
    "residence": "Berlin",
    "employer": "TechCorp",
    "skills": ["C", "Design"],
  };
}

  // Keep if we also want to save manually via button
  Future<void> saveManually() async {
    _debounceTimer?.cancel();
    await _saveContactToDatabase();
  }
}