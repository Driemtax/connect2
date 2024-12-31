import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class FullContact {
  ContactDetail contactDetail;
  List<Tag> tags;
  List<ContactNote> notes;
  // Relations that have been defined from this contact to others
  List<ContactRelation> outgoingContactRelations;
  // Relations that 
  List<ContactRelation> incomingContactRelations;
  Contact phoneContact;

  FullContact({
    required this.tags,
    required this.contactDetail,
    required this.phoneContact,
    required this.notes,
    required this.outgoingContactRelations,
    required this.incomingContactRelations
  });

  // Warning the tag has to be saved in t he database already
  Future<void> addTag(Tag tag) async {
    await ContactDetailTag(ContactDetailId: contactDetail.id, TagId: tag.id)
        .save();
  }

  // Searches if already a tag with that tagname exists. If thats the case its going to use this tag.
  // If thats not the case it creates a new Tag with that name
  Future<Tag> addTagByName(String tagName) async {
    Tag? tag = await Tag().select().name.equals(tagName).toSingle();
    tag ??= await _createNewTag(tagName);
    await addTag(tag);
    return tag;
  }

  Future<void> removeTag(Tag tag) async {
    await ContactDetailTag()
        .select()
        .TagId
        .equals(tag.id)
        .ContactDetailId
        .equals(contactDetail.id)
        .delete();
  }

  Future<ContactNote> addNewNote(String text, DateTime date) async {
    ContactNote newContactNote = await _createNewContactNode(text, date);
    return newContactNote;
  }

  void deleteNote(ContactNote note) async {
    await note.delete();
  }

  Future<ContactRelation> addContactRelation(String name, int toContactDetailId) async {
    ContactRelation newContactRelation =
        await _createNewContactRelation(name, toContactDetailId);
    return newContactRelation;
  }

  void deleteContactRelation(ContactRelation contactRelation) async {
    await contactRelation.delete();
  }

  Future<ContactRelation> _createNewContactRelation(
    String name,
    int toContactDetailId,
  ) async {
    int? newContactRelationId = await ContactRelation(
      name: name,
      fromId: contactDetail.id,
      toId: toContactDetailId,
    ).save();
    if (newContactRelationId != null) {
      ContactRelation? newContactRelation =
          await ContactRelation().getById(newContactRelationId);
      if (newContactRelation != null) {
        return newContactRelation;
      } else {
        throw DatabaseErrorException(
          'At this point newContactRelation should never be null!',
        );
      }
    } else {
      throw DatabaseErrorException(
        'Could not save a new ContactRelation into the Database',
      );
    }
  }

  Future<ContactNote> _createNewContactNode(String text, DateTime date) async {
    int? newContactNoteId = await ContactNote(
      note: text,
      date: date,
      ContactDetailId: contactDetail.id,
    ).save();
    if (newContactNoteId != null) {
      ContactNote? newContactNote =
          await ContactNote().getById(newContactNoteId);
      if (newContactNote != null) {
        return newContactNote;
      } else {
        throw DatabaseErrorException(
          'At this point newContactNote should never be null!',
        );
      }
    } else {
      throw DatabaseErrorException(
        'Could not save a new ContactNote into the Database',
      );
    }
  }

  Future<Tag> _createNewTag(String tagName) async {
    int? newTagId = await Tag(name: tagName).save();
    if (newTagId != null) {
      Tag? newTag = await Tag().getById(newTagId);
      if (newTag != null) {
        return newTag;
      } else {
        throw DatabaseErrorException(
          'At this point newTag should never be null!',
        );
      }
    } else {
      throw DatabaseErrorException(
        'Could not save a new Tag into the database',
      );
    }
  }
}
