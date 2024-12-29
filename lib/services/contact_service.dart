import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:connect2/provider/phone_contact_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  PhoneContactProvider phoneContactProvider = PhoneContactProvider();

  Future<List<Contact>> getAll() async {
    List<Contact> contacts = await phoneContactProvider.getAll();
    List<ContactDetail> contactDetails =
        await ContactDetail().select().toList();
    final contactDetailIds =
        contactDetails.map((detail) => detail.phoneContactId).toSet();

    final futures = contacts
        .where((contact) => !contactDetailIds.contains(contact.id))
        .map((contact) => ContactDetail(phoneContactId: contact.id).save());

    await Future.wait(futures);

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
    List<ContactRelation>? outgoingContactRelations =
        await contactDetail.getContactRelations()?.toList();
    outgoingContactRelations ??= [];
    List<ContactRelation>? incomingContactRelations =
        await contactDetail.getContactRelationsByto()?.toList();
    incomingContactRelations ??= [];
    FullContact fullContact = FullContact(
      tags: tags,
      contactDetail: contactDetail,
      phoneContact: phoneContact,
      notes: notes,
      outgoingContactRelations: outgoingContactRelations,
      incomingContactRelations: incomingContactRelations,
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
      incomingContactRelations: [],
      outgoingContactRelations: [],
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
