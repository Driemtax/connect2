import 'package:connect2/db/db_helper.dart';
import 'package:connect2/model/contact_detail_tag.dart';

class ContactDetailTagProvider {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertRelation(ContactDetailTag contactDetailTag) async {
    final db = await _dbHelper.database;
    return await db.insert('contact_detail_tag', contactDetailTag.toMap());
  }

  Future<int> removeRelation(ContactDetailTag contactDetailTag) async {
    final db = await _dbHelper.database;
    return await db.delete('contact_detail_tag',
        where: 'id = ?', whereArgs: [contactDetailTag.id]);
  }

  // There is currently no function to query single objects
  // I currently don't see the use of querying just relationships
}
