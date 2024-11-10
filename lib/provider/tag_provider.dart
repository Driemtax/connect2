import 'package:connect2/db/db_helper.dart';
import 'package:connect2/model/tag.dart';

class TagProvider {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertTag(Tag tag) async {
    final db = await _dbHelper.database;
    return await db.insert('tag', tag.toMap());
  }

  Future<List<Tag>> getTags() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tag');

    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }

  Future<Tag> getTag(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('tag', where: 'id = ?', whereArgs: [id]);

    return Tag.fromMap(maps[0]);
  }

  Future<List<Tag>> searchTags(String tagName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tag',
      where: 'name Like ?',
      whereArgs: ['%$tagName%'],
    );

    return List.generate(maps.length, (i) {
      return Tag.fromMap(maps[i]);
    });
  }
}
