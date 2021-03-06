import 'dart:convert';
import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music/class/song.dart';
import 'package:music/database/database.dart';
import 'package:music/database/downloadMusicDatabase.dart';
import 'package:music/json_convert/downLoadInfo.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/settings/dio_setting.dart';

class DownLoadInstance {
  // 单例公开访问点
  factory DownLoadInstance() => _getInstance();
  // 静态私有成员，没有初始化
  static DownLoadInstance _instance;
  static DownLoadInstance get instance => _getInstance();
  // 私有构造函数
  String _localPath;
  DownLoadInstance._internal();

  // 静态、同步、私有访问点
  static DownLoadInstance _getInstance() {
    if (_instance == null) {
      _instance = DownLoadInstance._internal();
    }
    return _instance;
  }

  Future<void> startDownLoad(SongList song, String url, String fileName) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: song.name + '.' + fileName,
      savedDir: _localPath,
      showNotification: false,
      openFileFromNotification: false,
    );
    final tempSong = jsonEncode(song);
    await DataBaseDownLoadListProvider.db.insetDB(
      taskId: taskId,
      song: tempSong.toString(),
      songId: song.id,
      songFileName: song.name + '.' + fileName,
    );
    await DataBaseMusicProvider.db.insetDB(taskId: taskId, musicId: song.id);
  }

  Future<void> getSongInfo(SongList song, SongType songType) async {
    String type = '', fileName;
    switch (songType) {
      case SongType.normal:
        type = '128';
        fileName = 'mp3';
        break;
      case SongType.high:
        type = '320';
        fileName = 'mp3';
        break;
      case SongType.undamaged:
        type = 'flac';
        fileName = 'flac';
        break;
      default:
    }
    try {
      Response response = await Dio(dioOptions).get(
          "http://api.migu.jsososo.com/song",
          queryParameters: {'id': song.id, 'type': type});
      Map songsMap = json.decode(response.toString());
      DownLoadFileInfo songInfo = new DownLoadFileInfo.fromJson(songsMap);
      if (songInfo.result == 100) {
        startDownLoad(song, songInfo.data.url, fileName);
      } else {
        showCenterShortToast();
      }
    } catch (e) {
      showCenterShortToast();
    }
  }

  Future<Null> prepare() async {
    String musicPath = await AndroidPathProvider.musicPath;
    _localPath = musicPath + Platform.pathSeparator + 'Downloads';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: "下载失败",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  Future<List<DownloadTask>> loadTasks() async {
    return await FlutterDownloader.loadTasks();
  }

  Future cancel(String taskId) async {
    FlutterDownloader.cancel(taskId: taskId);
  }

  Future pause(String taskId) async {
    FlutterDownloader.pause(taskId: taskId);
  }

  Future resume(String taskId) async {
    FlutterDownloader.resume(taskId: taskId);
  }

  Future retry(String taskId) async {
    FlutterDownloader.retry(taskId: taskId);
  }

  Future remove(String taskId) async {
    FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: false);
  }

  Future delete(String taskId) async {
    FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
  }

  Future cancelAll(String taskId) async {
    FlutterDownloader.cancelAll();
  }
}
