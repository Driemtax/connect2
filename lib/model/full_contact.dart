import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class FullContact {
  ContactDetail contactDetail;
  List<Tag> tags;
  List<ContactNote> notes;
  Contact phoneContact;
  
  FullContact({required this.tags, required this.contactDetail, required this.phoneContact, required this.notes});

  // Warning the tag has to be saved in t he database already
  void addTag(Tag tag) async {
    await ContactDetailTag(ContactDetailId: contactDetail.id, TagId: tag.id).save();
    tags.add(tag);
  }

  // Searches if already a tag with that tagname exists. If thats the case its going to use this tag.
  // If thats not the case it creates a new Tag with that name
  void addTagByName(String tagName) async {
    Tag? tag = await Tag().select().name.equals(tagName).toSingle();
    tag ??= await _createNewTag(tagName);
    addTag(tag);
  }

  void removeTag(Tag tag) async {
    await ContactDetailTag().select().TagId.equals(tag.id).ContactDetailId.equals(contactDetail.id).delete();
    tags.remove(tag);
  }

  void addNewNote(String text, DateTime date) async {
    ContactNote newContactNote = await _createNewContactNode(text, date);
    notes.add(newContactNote);
  }

  void deleteNote(ContactNote note) async {
    await note.delete();
    notes.remove(note);
  } 

  Future<ContactNote> _createNewContactNode(String text, DateTime date) async {
    int? newContactNoteId = await ContactNote(note: text, date: date, ContactDetailId: contactDetail.id).save();
    if (newContactNoteId != null) {
      ContactNote? newContactNote = await ContactNote().getById(newContactNoteId);
      if (newContactNote != null) {
        return newContactNote;
      } else {
        throw DatabaseErrorException('At this point newContactNote should never be null!');
      }
    } else {
      throw DatabaseErrorException('Could not save a new ContactNote into the Database');
    }
  }

  Future<Tag> _createNewTag(String tagName) async {
    int? newTagId = await Tag(name: tagName).save();
    if (newTagId != null) {
      Tag? newTag = await Tag().getById(newTagId);
      if (newTag != null) {
        return newTag;
      } else {
        throw DatabaseErrorException('At this point newTag should never be null!');
      }
    } else {
      throw DatabaseErrorException('Could not save a new Tag into the database');
    }
  }
}