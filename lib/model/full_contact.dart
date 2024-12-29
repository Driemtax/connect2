import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class FullContact {
  ContactDetail contactDetail;
  List<Tag> tags;
  Contact phoneContact;
  
  FullContact({required this.tags, required this.contactDetail, required this.phoneContact});

  void addTag(Tag tag) async {
    await ContactDetailTag(ContactDetailId: contactDetail.id, TagId: tag.id).save();
    tags.add(tag);
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
      throw DatabaseErrorException('Could save a new Tag into the database');
    }
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
}