import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:connect2/provider/phone_contact_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  PhoneContactProvider phoneContactProvider = PhoneContactProvider();

  /// Can be used for the list view
  Future<List<Contact>> getAll() async {
    List<Contact> contacts = await phoneContactProvider.getAll();
    return contacts;
  }

  /// getFullContact
  Future<FullContact> getFullContact(String phoneContactId) async {
    Contact phoneContact = await phoneContactProvider.get(phoneContactId);
    ContactDetail? contactDetail = await ContactDetail()
        .select()
        .phoneContactId
        .equals(phoneContactId)
        .toSingle();
    contactDetail ??= await _createNewContactDetail(phoneContactId);
    List<Tag>? tags = await contactDetail.getTags()?.toList();
    tags ??= [];
    List<ContactNote>? notes = await contactDetail.getContactNotes()?.toList();
    notes ??= [];
    FullContact fullContact = FullContact(
      tags: tags,
      contactDetail: contactDetail,
      phoneContact: phoneContact,
      notes: notes,
    );
    return fullContact;
  }

  void updateFullContact(FullContact fullContact) async {
    await phoneContactProvider.saveModified(fullContact.phoneContact);
    await fullContact.contactDetail.save();
  }

  // To Create a new Full Contact you will have to create a phoneContact so a normal Contact object.
  // The phoneContact is not allowed to have an id when its getting created! Otherwise its going to fail!
  Future<FullContact> createFullContact(Contact phoneContact) async {
    Contact newPhoneContact = await phoneContactProvider.saveNew(phoneContact);
    ContactDetail newContactDetail =
        await _createNewContactDetail(newPhoneContact.id);
    FullContact newFullContact = FullContact(
      tags: [],
      notes: [],
      contactDetail: newContactDetail,
      phoneContact: newPhoneContact,
    );
    return newFullContact;
  }

  /// create a new Contact Detail with a phoneContactId
  Future<ContactDetail> _createNewContactDetail(String phoneContactId) async {
    int? newContactDetailId =
        await ContactDetail(phoneContactId: phoneContactId).save();
    if (newContactDetailId != null) {
      ContactDetail? contactDetail =
          await ContactDetail().getById(newContactDetailId);
      if (contactDetail != null) {
        return contactDetail;
      } else {
        throw DatabaseErrorException(
            'contactDetail should always be defined at this point!');
      }
    } else {
      throw DatabaseErrorException(
          'Could not save a new ContactDetail into the database');
    }
  }
}
