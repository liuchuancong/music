import 'dart:async';

import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 注册时模拟表
class MusicMenuDatabaseInstance {
  Database _database;
  Future<Database> get dataBase async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  String _tableName, _dbName;
  factory MusicMenuDatabaseInstance(id) => _getInstance(id);
  // 静态私有成员，没有初始化
  static MusicMenuDatabaseInstance _instance;
  // 私有构造函数
  MusicMenuDatabaseInstance._internal(tableName, dbName) {
    this._tableName = tableName;
    this._dbName = dbName;
  }

  // 静态、同步、私有访问点
  static MusicMenuDatabaseInstance _getInstance(id) {
    final String tableName = 'MusicMenu' + id;
    final String dbName = 'music_menu_' + id + '.db';
    _instance = MusicMenuDatabaseInstance._internal(tableName, dbName);
    return _instance;
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
    String path = join(savedDir.path, _dbName);
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE $_tableName ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "song VARCHAR ( 256 ),"
          "song_id VARCHAR ( 256 )"
          ")",
        );
      },
    );
  }

  Future insetDB({String song, String songId}) async {
    Database db = await dataBase;
    await db.insert(_tableName, {'song': song, 'song_id': songId});
  }

  Future<List<MusicMenu>> queryAll() async {
    var db = await dataBase;
    var result = await db.query(_tableName);
    List<MusicMenu> list = result.isNotEmpty
        ? result.map((music) => MusicMenu.formMap(music)).toList()
        : [];
    return list;
  }

  Future<bool> hasSaved(String musicId) async {
    var db = await dataBase;
    var result =
        await db.rawQuery("SELECT * FROM $_tableName WHERE song_id=$musicId");
    bool _hasSaved = result.isNotEmpty ? true : false;
    return _hasSaved;
  }
  Future deleteMenuWithId(String musicId) async {
    var db = await dataBase;
    await db.rawQuery("DELETE FROM $_tableName WHERE song_id=$musicId");
  }
}

class MusicMenu {
  int id;
  String song;
  String songId;
  MusicMenu({this.id, this.song, this.songId});

  factory MusicMenu.formMap(Map<String, dynamic> json) => new MusicMenu(
        id: json['id'],
        song: json['song'],
        songId: json['song_id'],
      );

  Map<String, dynamic> toMap() => {'id': id, 'song': song, 'song_id': songId};
}
