import 'dart:math';

import 'package:connect2/components/graph_view/node.dart';
import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:connect2/provider/phone_contact_provider.dart';
import 'package:flutter/services.dart';
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
        await ContactRelation().select().fromId.equals(contactDetail.id).toList();
    List<ContactRelation>? incomingContactRelations =
        await ContactRelation().select().toId.equals(contactDetail.id).toList();
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

  Future<List<Node>> getGraphViewNodes() async {
    List<Node> nodes = [];
    Random random = Random();
    // Making sure all the nessary contactDetails have been created.
    // It throws some performance out of the window, but it catches some
    // very nasty errors, so i dont have a problem with it for now.
    await getAll();

    // CREATING ALL THE NEEDED NODES

    // creating the contact nodes
    List<ContactDetail> contactDetails =
        await ContactDetail().select().toList();
    final Map<int, Node> contactNodeMap = {};

    final contactDetailNodeFutures = contactDetails.map((contactDetail) async {
      String? phoneContactId = contactDetail.phoneContactId;
      if (phoneContactId != null) {
        Node newNode = await _createNodeFromContact(random, phoneContactId);
        int? contactDetailId = contactDetail.id;
        if (contactDetailId != null) {
          contactNodeMap[contactDetailId] = newNode;
          nodes.add(newNode);
        }
      }
    });

    await Future.wait(contactDetailNodeFutures);

    // creating the tag nodes
    final Map<int, Node> tagNodeMap = {};
    List<Tag> tags = await Tag().select().toList();
    for (var tag in tags) {
      Node newNode = _createNodeFromTag(random, tag);
      int? tagId = tag.id;
      if (tagId != null) {
        tagNodeMap[tagId] = newNode;
        nodes.add(newNode);
      }
    }

    // ADDING RELATIONS BETWEEN THE NODES

    // adding the relations between contacts
    List<ContactRelation> contactRelations = await ContactRelation().select().toList();
    for (var contactRelation in contactRelations) {
      Node? fromNode = contactNodeMap[contactRelation.fromId];
      Node? toNode = contactNodeMap[contactRelation.toId];
      if (fromNode != null && toNode != null) {
        connectNodes(fromNode, toNode);
      }
    }

    // adding the relations from contacts to tags
    List<ContactDetailTag> contactTagRelations = await ContactDetailTag().select().toList();
    for (var contactTagRelation in contactTagRelations) {
      Node? fromNode = contactNodeMap[contactTagRelation.ContactDetailId];
      Node? toNode = tagNodeMap[contactTagRelation.TagId];
      if (fromNode != null && toNode != null) {
        connectNodes(fromNode, toNode);
      }
    }

    return nodes;
  }

  Future<Node> _createNodeFromContact(
      Random random, String phoneContactId) async {
    Contact phoneContact = await phoneContactProvider.get(phoneContactId);
    Node newNode = Node(
      Offset(random.nextDouble() * 256, random.nextDouble() * 256),
      [],
      NodeType.node,
      phoneContact.displayName,
    );
    return newNode;
  }

  Node _createNodeFromTag(Random random, Tag tag) {
    Node newNode = Node(
      Offset(random.nextDouble() * 256, random.nextDouble() * 256),
      [],
      NodeType.tag,
      tag.name ?? '',
    );
    return newNode;
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
