import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
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
  // TODO Delete method, when no references anymore
  void updateContactField(String field, dynamic value) {
    contactData[field] = value;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      
    });
  }

  void updateDebouncing(FullContact updatedContact) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _service.updateFullContact(updatedContact);
    });
  }

  Future<FullContact> loadContactFromDatabase() async {
    // Simuliere das Laden von Daten aus der Datenbank
    await Future.delayed(const Duration(seconds: 1)); // Simulates Loading Time for now
    FullContact contact = await _service.getFullContact(phoneContactId);

    return contact;
  }

  Future<void> saveImageToContact(File imageFile, FullContact contact) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    contact.phoneContact.photo = imageBytes;
    _service.updateFullContact(contact);
  }
}