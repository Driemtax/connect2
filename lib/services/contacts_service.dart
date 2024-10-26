import 'package:flutter_contacts/flutter_contacts.dart';

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class ContactNotFoundException implements Exception {
  final String message;
  ContactNotFoundException(this.message);

  @override
  String toString() => 'ContactNotFoundException: $message';
}


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
