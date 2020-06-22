import 'dart:async';

import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 注册时模拟表
class DataBasePlayListProvider {
  DataBasePlayListProvider._();
  static final table = 'PlayList';
  static final DataBasePlayListProvider db = DataBasePlayListProvider._();
  Database _database;
  Future<Database> get dataBase async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    /// On Android, this returns the AppData directory.
    String musicPath = await AndroidPathProvider.musicPath;
    String _localPath = musicPath + Platform.pathSeparator + 'DataBase';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    String path = join(savedDir.path, "play_list.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE $table ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "menu_name VARCHAR ( 256 ),"
          "menu_cover VARCHAR ( 256 )"
          ")",
        );
      },
    );
  }

  Future insetDB({String menuName, String menuCover}) async {
    Database db = await dataBase;
    await db.insert(table, {'menu_name': menuName, 'menu_cover': menuCover});
  }

  Future<List<PlayListDBInfoMation>> queryAll() async {
    var db = await dataBase;
    var result = await db.query(table);
    List<PlayListDBInfoMation> list = result.isNotEmpty
        ? result.map((music) => PlayListDBInfoMation.formMap(music)).toList()
        : [];
    return list;
  }

  Future deleteMenuWithId(int menuId) async {
    var db = await dataBase;
    await db.rawQuery(
        "DELETE FROM $table WHERE id=$menuId");
  }
}

class PlayListDBInfoMation {
  int id;
  String menuName;
  String menuCover;
  PlayListDBInfoMation({this.id, this.menuName, this.menuCover});

  factory PlayListDBInfoMation.formMap(Map<String, dynamic> json) =>
      new PlayListDBInfoMation(
        id: json['id'],
        menuName: json['menu_name'],
        menuCover: json['menu_cover'],
      );

  Map<String, dynamic> toMap() =>
      {'id': id, 'menu_name': menuName, 'menu_cover': menuCover};
}
