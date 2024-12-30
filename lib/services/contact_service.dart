import 'dart:math';

import 'package:connect2/components/graph_view/node.dart';
import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:connect2/provider/phone_contact_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// A service for managing contacts and their associated data, including 
/// tags, notes, relationships, and visualization in a graph view.
class ContactService {
  /// A provider to fetch and save phone contacts.
  PhoneContactProvider phoneContactProvider = PhoneContactProvider();

  /// Fetches all phone contacts and ensures their corresponding contact details
  /// are created in the database.
  ///
  /// This method:
  /// - Fetches all contacts from the phone.
  /// - Checks if corresponding `ContactDetail` entries exist.
  /// - Creates new `ContactDetail` entries for contacts that are not yet in the database.
  ///
  /// Returns:
  /// - A [Future] resolving to a list of all [Contact] objects.
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

  /// Fetches the full details of a contact, including associated tags, notes, 
  /// and relationships.
  ///
  /// Parameters:
  /// - [phoneContactId]: The unique ID of the phone contact.
  ///
  /// Returns:
  /// - A [Future] resolving to a [FullContact] object containing the contact's
  ///   details, tags, notes, and relationships.
  ///
  /// Throws:
  /// - [DatabaseErrorException] if the contact cannot be fetched or saved.
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

  /// Updates a full contact's details and saves modifications to the database.
  ///
  /// Parameters:
  /// - [fullContact]: The [FullContact] object with updated data to save.
  ///
  /// This method saves both the phone contact and the contact detail information.
  void updateFullContact(FullContact fullContact) async {
    await phoneContactProvider.saveModified(fullContact.phoneContact);
    await fullContact.contactDetail.save();
  }

  /// Creates a new full contact by saving a new phone contact and
  /// initializing associated contact details.
  ///
  /// Parameters:
  /// - [phoneContact]: A [Contact] object representing the new phone contact.
  ///   Ensure the contact has no ID, as the ID is generated during creation.
  ///
  /// Returns:
  /// - A [Future] resolving to the newly created [FullContact].
  ///
  /// Throws:
  /// - [DatabaseErrorException] if the contact cannot be created.
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

  /// Generates a list of nodes representing contacts and tags, 
  /// along with their relationships, for visualization in a graph view.
  ///
  /// This method:
  /// - Ensures all `ContactDetail` entries exist.
  /// - Creates nodes for all contacts and tags.
  /// - Adds edges between related nodes.
  ///
  /// Returns:
  /// - A [Future] resolving to a list of [Node] objects for the graph.
  ///
  /// Notes:
  /// - This method may affect performance due to database integrity checks.
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

  /// Creates a node representing a contact for the graph view.
  ///
  /// Parameters:
  /// - [random]: A [Random] instance for generating random node positions.
  /// - [phoneContactId]: The unique ID of the phone contact.
  ///
  /// Returns:
  /// - A [Future] resolving to a [Node] object.
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

  /// Creates a node representing a tag for the graph view.
  ///
  /// Parameters:
  /// - [random]: A [Random] instance for generating random node positions.
  /// - [tag]: The [Tag] object to create a node for.
  ///
  /// Returns:
  /// - A [Node] object.
  Node _createNodeFromTag(Random random, Tag tag) {
    Node newNode = Node(
      Offset(random.nextDouble() * 256, random.nextDouble() * 256),
      [],
      NodeType.tag,
      tag.name ?? '',
    );
    return newNode;
  }

  /// Creates a new `ContactDetail` entry in the database for a given phone contact.
  ///
  /// Parameters:
  /// - [phoneContactId]: The unique ID of the phone contact.
  ///
  /// Returns:
  /// - A [Future] resolving to the newly created [ContactDetail].
  ///
  /// Throws:
  /// - [DatabaseErrorException] if the contact detail cannot be saved.
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
