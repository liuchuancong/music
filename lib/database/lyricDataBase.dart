import 'dart:async';

import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 注册时模拟表
class LyricDataBaseProvider {
  LyricDataBaseProvider._();
  static final table = 'lyric';
  static final LyricDataBaseProvider db = LyricDataBaseProvider._();
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
    String path = join(savedDir.path, "lyric.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE $table ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "lyric VARCHAR ( 256 ),"
          "c_id VARCHAR ( 256 )"
          ")",
        );
      },
    );
  }

  Future insetDB({String lyric, String cId}) async {
    Database db = await dataBase;
    await db.insert(table, {'lyric': lyric, 'c_id': cId});
  }

  Future<List<LyricDBInfoMation>> queryLyricWithcId(String cId) async {
    var db = await dataBase;
    var result = await db
        .rawQuery("SELECT * FROM $table WHERE c_id='${cId.toString()}'");
    List<LyricDBInfoMation> list = result.isNotEmpty
        ? result.map((music) => LyricDBInfoMation.formMap(music)).toList()
        : [];
    return list;
  }
}

class LyricDBInfoMation {
  final int id;
  final String lyric;
  final String cId;
  LyricDBInfoMation({this.id,this.lyric, this.cId});

  factory LyricDBInfoMation.formMap(Map<String, dynamic> json) =>
      new LyricDBInfoMation(
        lyric: json['lyric'],
        cId: json['c_id'],
      );

  Map<String, dynamic> toMap() => {'lyric': lyric, 'c_id': cId};
}
