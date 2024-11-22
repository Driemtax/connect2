import 'package:connect2/db/db_helper.dart';
import 'package:connect2/model/contact_detail_relation.dart';

class ContactDetailRelationProvider {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertRelation(
      ContactDetailRelation contactDetailReleation) async {
    final db = await _dbHelper.database;
    return await db.insert(
        'contact_detail_relation', contactDetailReleation.toMap());
  }

  Future<int> removeRelation(
      ContactDetailRelation contactDetailReleation) async {
    final db = await _dbHelper.database;
    return await db.delete('contact_detail_tag',
        where: 'id = ?', whereArgs: [contactDetailReleation.id]);
  }

  // There is currently no function to query single objects
  // I currently don't see the use of querying just relationships
}
