import 'package:connect2/db/db_helper.dart';
import 'package:connect2/model/contact_detail.dart';

class ContactDetailProvider {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertContactDetail(ContactDetail contactDetail) async {
    final db = await _dbHelper.database;
    return await db.insert('contact_detail', contactDetail.toMap());
  }

  Future<List<ContactDetail>> getContactDetails() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('contact_detail');

    return List.generate(maps.length, (i) {
      return ContactDetail.fromMap(maps[i]);
    });
  }
}
