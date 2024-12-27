import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:connect2/exceptions/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Retrieves a list of all contacts from the device's contact list.
///
/// This function checks if the app has permission to access contacts.
/// If permission is granted, it retrieves and returns a list of `Contact`
/// objects. If permission is denied, it throws a `PermissionDeniedException`.
///
/// - Returns: A `List` of `Contact` objects if permission is granted.
/// - Throws: `PermissionDeniedException` if the app does not have contact permissions.
Future<List<Contact>> getContacts() async {
  if (await FlutterContacts.requestPermission()) {
    return await FlutterContacts.getContacts();
  } else {
    throw PermissionDeniedException('Contact permissions were not granted.');
  }
}

/// Retrieves a specific contact based on the given ID.
///
/// This function checks if the app has permission to access contacts.
/// If permission is granted, it attempts to retrieve the contact with the
/// specified `id`. If the contact is found, it returns the `Contact` object.
/// If the contact is not found, it throws a `ContactNotFoundException`.
/// If permission is denied, it throws a `PermissionDeniedException`.
///
/// - Parameter id: The unique identifier of the contact to retrieve.
/// - Returns: A `Contact` object if the contact is found and permission
///            is granted.
/// - Throws: `PermissionDeniedException` if the app does not have contact permissions,
///           `ContactNotFoundException` if the contact cannot be found.
Future<Contact> getContact(String id) async {
  if (await FlutterContacts.requestPermission()) {
    Contact? contact = await FlutterContacts.getContact(id);
    if (contact != null) {
      return contact;
    } else {
      throw ContactNotFoundException('Contact with id $id was not found.');
    }
  } else {
    throw PermissionDeniedException('Contact permissions were not granted.');
  }
}

/// Saves the modified contact by updating it in the device's contact list.
///
/// This function takes a modified `Contact` object and saves it.
/// If permission is not granted, it throws an exception.
///
/// - Parameter contact: The modified `Contact` object to save.
/// - Throws: `PermissionDeniedException` if contact permissions are not granted.
Future<void> saveModifiedContact(Contact contact) async {
  if (await FlutterContacts.requestPermission()) {
    try {
      await FlutterContacts.updateContact(contact);
    } catch (e) {
      throw Exception('Failed to update contact: ${e.toString()}');
    }
  } else {
    throw PermissionDeniedException('Contact permissions were not granted.');
  }
}

/// Saves a new contact in the device's contact list.
///
/// This function takes a `Contact` object, requests permission to access
/// contacts, and saves the contact as a new entry in the contact list.
/// If permission is not granted, it throws an exception.
///
/// - Parameter contact: The `Contact` object to save as a new contact.
/// - Throws: `PermissionDeniedException` if contact permissions are not granted.
Future<int> saveNewContact(Contact contact) async {
  if (await FlutterContacts.requestPermission()) {
    try {
      contact = await FlutterContacts.insertContact(contact);
      // contact.displayName = name;
      // await FlutterContacts.updateContact(contact);
    } catch (e) {
      throw Exception('Failed to save new contact: ${e.toString()}');
    }
  } else {
    throw PermissionDeniedException('Contact permissions were not granted.');
  }
  return int.parse(contact.id);
}

// Saves the id of the users own contact.
///
/// This method takes an id and stores it in the shared preferences. This function will only be called once.
///
/// - Parameter contactId: String, the contactId of the users own contact.
Future<void> saveOwnContactId(String contactId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('own_contact_id', contactId);
}

Future<String?> getOwnContactId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('own_contact_id');
}


Future<Contact?> getOwnContact() async {
  final contactId = await getOwnContactId();
  if (contactId != null) {
    final contacts = await FlutterContacts.getContacts();
    try {
      return contacts.firstWhere((c) => c.id == contactId);
    } catch (e) {
      return null;
    }
  }
  return null;
}
