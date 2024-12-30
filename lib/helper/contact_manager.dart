import 'dart:async';

import 'package:connect2/model/full_contact.dart';
import 'package:connect2/services/contact_service.dart';

class ContactManager {
  final String phoneContactId;
  final ContactService _service = ContactService();
  Map<String, dynamic> contactData = {};
  FullContact? contact;
  Timer? _debounceTimer;

  ContactManager(this.phoneContactId, this.contactData);

  ContactManager.withId(this.phoneContactId) {
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

  void updateFullContact(FullContact updatedContact) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _service.updateFullContact(updatedContact);
    });
  }

  Future<void> _saveContactToDatabase() async {
    // TODO Update database here

    // await database.update(contactId, contactData);
  }

  Future<FullContact> loadContactFromDatabase() async {
    // Simuliere das Laden von Daten aus der Datenbank
    await Future.delayed(const Duration(seconds: 1)); // Simulates Loading Time for now
    FullContact contact = await _service.getFullContact(phoneContactId);

    return contact;
  }
}