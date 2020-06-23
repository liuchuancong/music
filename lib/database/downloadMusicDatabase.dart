import 'dart:async';

import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 注册时模拟表
class DataBaseDownLoadListProvider {
  DataBaseDownLoadListProvider._();
  static final table = 'DownLoadPlayList';
  static final DataBaseDownLoadListProvider db =
      DataBaseDownLoadListProvider._();
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
    String path = join(savedDir.path, "download_play_list.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE $table ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "song VARCHAR ( 256 ),"
          "song_id VARCHAR ( 256 ),"
          "song_file_name VARCHAR ( 256 ),"
          "task_id VARCHAR ( 256 )"
          ")",
        );
      },
    );
  }

  Future insetDB({
    String song,
    String taskId,
    String songId,
    String songFileName,
  }) async {
    Database db = await dataBase;
    await db.insert(table, {
        'song': song,
        'song_id': songId,
        'song_file_name': songFileName,
        'task_id': taskId});
  }

  Future<List<DwonloadDBInfoMation>> queryAll() async {
    var db = await dataBase;
    var result = await db.query(table);
    List<DwonloadDBInfoMation> list = result.isNotEmpty
        ? result.map((music) => DwonloadDBInfoMation.formMap(music)).toList()
        : [];
    return list;
  }

  Future deleteMenuWithId(int songId) async {
    var db = await dataBase;
    await db.rawQuery("DELETE FROM $table WHERE id=$songId");
  }
}

class DwonloadDBInfoMation {
  int id;
  String song;
  String taskId;
  String songId;
  String songFileName;
  DwonloadDBInfoMation(
      {this.id, this.song, this.taskId, this.songId, this.songFileName});

  factory DwonloadDBInfoMation.formMap(Map<String, dynamic> json) =>
      new DwonloadDBInfoMation(
        id: json['id'],
        song: json['song'],
        songId: json['song_id'],
        songFileName: json['song_file_name'],
        taskId: json['task_id'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'song': song,
        'song_id': songId,
        'song_file_name': songFileName,
        'task_id': taskId
      };
}
