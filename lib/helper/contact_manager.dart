import 'dart:async';

import 'package:flutter/material.dart';

class ContactManager {
  final int contactId;
  Map<String, dynamic> contactData = {};
  Timer? _debounceTimer;

  ContactManager(this.contactId, this.contactData);

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

  // Keep if we also want to save manually via button
  Future<void> saveManually() async {
    _debounceTimer?.cancel();
    await _saveContactToDatabase();
  }
}
