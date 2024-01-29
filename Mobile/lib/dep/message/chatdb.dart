import 'dart:convert';
import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DBChat {
  Database? _database;

  DBChat() {
    open();
  }

  Future<void> open() async {
    try {
      print('[DBOpen] Opening database...');
      _database = await openDatabase(
        'messages.db',
        version: 1,
        onCreate: (db, version) {
          print('[DBOpen] Generating a new table for all the messages...');
          db.execute('''
            CREATE TABLE IF NOT EXISTS messages (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              User01 TEXT NOT NULL,
              User02 TEXT NOT NULL,
              Content TEXT NOT NULL DEFAULT 'Unknown Content',
              Time TEXT NOT NULL,
              Type TEXT NOT NULL DEFAULT 'txt'
            );
          ''');
        },
      );
    } catch (e) {
      print('[ERROR] Database error occurred: $e');
    }
  }

  Future<void> rstall() async {
    print('[DBRST] Deleting the database...');
    print('[WARNG] Dont interrupt this process!');
    await deleteDatabase('messages.db');
    print('[DBRST] Database has been deleted successfully!');
  }

  Future<void> addmsg(String author, String createdAt, int id, String text, String remoteId) async {
    try {
      await _database?.execute(
        'INSERT INTO messages (id, User01, User02, Content, Time, Type) VALUES (?, ?, ?, ?, ?, ?)',
        [id, author, remoteId, text, createdAt, 'txt'],
      ).then((_) {
        print('[ADDMSG] (txt) $id - $author --> $remoteId: $text @ $createdAt');
      });
    } catch (e) {
      if (e.toString().contains('UNIQUE')) {
        print('[ADDMSG] Message $id is already available in the database.');
      } else {
        print('[ADDMSG] Some wild error occurred : $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String friendID, int page) async {
    final token = await getToken();
    var response = await http.get(
      Uri.parse('$hostname/data/id'),
      headers: {'auth': token!},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String userID = data['ID'];

      try {
        int offset = (page - 1) * 15;

        List<Map<String, Object?>> result = (await _database?.rawQuery(
          'SELECT * FROM messages WHERE (User01 = ? AND User02 = ?) OR (User02 = ? AND User01 = ?) ORDER BY Time DESC LIMIT 15 OFFSET ?',
          [userID, friendID, userID, friendID, offset],
        ))!;

        for (var message in result) {
          print('User01: ${message['User01']}, Content: ${message['Content']}, Time: ${message['Time']}');
        }

        print('[DBRest] Successful!');
        return result;
      } catch (e) {
        print('[DBRest] Database error occurred: $e');
        return [];
      }
    } else {
      return [];
    }
  }
}
