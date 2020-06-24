import 'dart:async';

import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 注册时模拟表
class DataBaseMusicProvider {
  DataBaseMusicProvider._();
  static final table = 'music';
  static final DataBaseMusicProvider db = DataBaseMusicProvider._();
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
    String path = join(savedDir.path, "songs.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE $table ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "task_id VARCHAR ( 256 ),"
          "music_id VARCHAR ( 256 )"
          ")",
        );
      },
    );
  }

  Future insetDB({String taskId, String musicId}) async {
    Database db = await dataBase;
    await db.insert(table, {'task_id': taskId, 'music_id': musicId});
  }

  Future queryMusic(String taskId) async {
    var db = await dataBase;
    var result =
        await db.rawQuery("SELECT * FROM $table WHERE task_id='${taskId.toString()}'");
    List<MusicDBInfoMation> list = result.isNotEmpty
        ? result.map((music) => MusicDBInfoMation.formMap(music)).toList()
        : [];
    return list;
  }
   Future deleteMusicWithId(String musicId) async {
    var db = await dataBase;
    await db.rawQuery("DELETE FROM $table WHERE music_id='${musicId.toString()}'");
  }
    Future queryMusicWithMusicId(String musicId) async {
    var db = await dataBase;
    var result =
        await db.rawQuery("SELECT * FROM $table WHERE music_id='${musicId.toString()}'");
    List<MusicDBInfoMation> list = result.isNotEmpty
        ? result.map((music) => MusicDBInfoMation.formMap(music)).toList()
        : [];
    return list;
  }
}

class MusicDBInfoMation {
  String taskId;
  String musicId;
  MusicDBInfoMation({this.taskId, this.musicId});

  factory MusicDBInfoMation.formMap(Map<String, dynamic> json) =>
      new MusicDBInfoMation(
        taskId: json['task_id'],
        musicId: json['music_id'],
      );

  Map<String, dynamic> toMap() => {'task_id': taskId, 'music_id': musicId};
}
