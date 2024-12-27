import 'dart:async';

import 'package:connect2/services/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactManager {
  final int? contactId;
  Map<String, dynamic> contactData = {};
  Timer? _debounceTimer;

  ContactManager(this.contactId, this.contactData);

  ContactManager.withId(this.contactId) {
    contactData = {};
  }

  ContactManager.empty() :
    contactId = null,
    contactData = {};

  // Method will be called on every change
  void updateContactField(String field, dynamic value) {
    contactData[field] = value;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _saveContactToDatabase();
    });
  }

  Future<void> _saveContactToDatabase() async {
    print("Speichere Kontakt in der Datenbank: $contactData");
    // TODO Update database here
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
