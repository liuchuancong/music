import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music/database/database.dart';
import 'package:music/json_convert/downLoadInfo.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/json_convert/songs.dart' as songs;

class AudioInstance {
  // 单例公开访问点
  factory AudioInstance() => _getInstance();
  bool get isPlay => assetsAudioPlayer.isPlaying.value;
  // 静态私有成员，没有初始化
  static AudioInstance _instance;
  static AudioInstance get instance => _getInstance();
  AssetsAudioPlayer assetsAudioPlayer;
  // 私有构造函数
  AudioInstance._internal() {
    assetsAudioPlayer = new AssetsAudioPlayer();
  }

  // 静态、同步、私有访问点
  static AudioInstance _getInstance() {
    if (_instance == null) {
      _instance = AudioInstance._internal();
    }
    return _instance;
  }

  static Audio _audio;
  Future<void> initAudio(SongList song) async {
    if (isPlay) {
      stop();
    }
    try {
      _audio = Audio.network(
        song.url,
        metas: Metas(
          title: song.name,
          artist: song.artists[0].name,
          album: song.album.name,
          image:
              MetasImage.network(song.album.picUrl), //can be MetasImage.network
        ),
      );
      await assetsAudioPlayer.open(_audio, showNotification: true);
      updateMetas(song);
    } catch (t) {
      //mp3 unreachable
    }
  }

  Future<SongList> _getFileInfo(DownloadTask song) async {
    SongList musicInfo;
    List<MusicDBInfoMation> list =
        await DataBaseMusicProvider.db.queryMusic(song.taskId);
    String misicId = list[0].musicId;
    Response response = await Dio().get("http://api.migu.jsososo.com/song",
        queryParameters: {'id': misicId});
    Map songsMap = json.decode(response.toString());
    DownLoadFileInfo songInfo = new DownLoadFileInfo.fromJson(songsMap);
    if (songInfo.result == 100) {
      var artists = new List<songs.Artists>();
      artists.add(new songs.Artists(
          id: songInfo.data.artists[0].id,
          name: songInfo.data.artists[0].name));
      musicInfo = songs.SongList(
        name: songInfo.data.name,
        id: songInfo.data.id,
        cid: songInfo.data.cid,
        mvId: '',
        album: songs.Album(
          picUrl: songInfo.data.album.picUrl,
          id: songInfo.data.album.id,
          name: songInfo.data.album.name,
        ),
        artists: artists,
      );
    }
    return musicInfo;
  }

  Future<void> initFileAudio(String url, song) async {
    if (isPlay) {
      stop();
    }

    try {
      _audio = Audio.file(
        url,
        metas: Metas(
          title: song.name,
          artist: song.artists[0].name,
          album: song.album.name,
          image:
              MetasImage.network(song.album.picUrl), //can be MetasImage.network
        ),
      );
      await assetsAudioPlayer.open(_audio, showNotification: true);
      updateMetas(song);
    } catch (t) {
      //mp3 unreachable
    }
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: "请先添加歌曲",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  Future<void> initAudioList(List<SongList> songsList) async {
    if (songsList.length == 0) {
      showCenterShortToast();
      return;
    }
    try {
      List<Audio> playList = songsList
          .map((song) => Audio.network(
                song.url,
                metas: Metas(
                  title: song.name,
                  artist: song.artists[0].name,
                  album: song.album.name,
                  image: MetasImage.network(
                      song.album.picUrl), //can be MetasImage.network
                ),
              ))
          .toList();
      if (isPlay) {
        stop();
      }
      assetsAudioPlayer.open(
        Playlist(audios: playList),
        loopMode: LoopMode.playlist,
        showNotification: true,
      );
    } catch (t) {
      //mp3 unreachable
    }
  }

  Future<List<SongList>> initAudioFileList(List<DownloadTask> songsList) async {
    List<SongList> musicInfoList = [];
    if (songsList.length == 0) {
      showCenterShortToast();
      return musicInfoList;
    }

    try {
      List<Audio> playList = [];
      for (var i = 0; i < songsList.length; i++) {
        DownloadTask song = songsList[i];
        SongList musicInfo = await _getFileInfo(song);
        musicInfoList.add(musicInfo);
        String path = song.savedDir + Platform.pathSeparator + song.filename;
        playList.add(Audio.file(
          path,
          metas: Metas(
            title: musicInfo.name,
            artist: musicInfo.artists[0].name,
            album: musicInfo.album.name,
            image: MetasImage.network(
              musicInfo.album.picUrl,
            ), //can be MetasImage.network
          ),
        ));
      }
      if (isPlay) {
        stop();
      }
      assetsAudioPlayer.open(
        Playlist(audios: playList),
        loopMode: LoopMode.playlist,
        showNotification: true,
      );
    } catch (t) {
      //mp3 unreachable
    }
    return musicInfoList;
  }

  updateMetas(SongList song) {
    if (_audio != null) {
      _audio.updateMetas(
        title: song.name,
        artist: song.artists[0].name,
        album: song.album.name,
        image: MetasImage.network(song.album.picUrl), //c
      );
    }
  }

  Future<void> seekBy(Duration by) async {
    await assetsAudioPlayer.seekBy(by);
  }

  Future<void> insetAtIndex(int index, SongList song) async {
    var audio = Audio.network(
      song.url,
      metas: Metas(
        title: song.name,
        artist: song.artists[0].name,
        album: song.album.name,
        image:
            MetasImage.network(song.album.picUrl), //can be MetasImage.network
      ),
    );
    AudioInstance().assetsAudioPlayer.playlist.audios.insert(index, audio);
  }

  Future<void> add(SongList song) async {
    var audio = Audio.network(
      song.url,
      metas: Metas(
        title: song.name,
        artist: song.artists[0].name,
        album: song.album.name,
        image:
            MetasImage.network(song.album.picUrl), //can be MetasImage.network
      ),
    );
    AudioInstance().assetsAudioPlayer.playlist.add(audio);
  }

  Future<void> reMoveAtIndex(int index) async {
    AudioInstance().assetsAudioPlayer.playlist.audios.removeAt(index);
  }

  Future<void> playlistPlayAtIndex(int index) async {
    await assetsAudioPlayer.playlistPlayAtIndex(index);
  }

  Future<void> seek(Duration by) async {
    await assetsAudioPlayer.seek(by);
  }

  Future<void> playOrPause() async {
    await assetsAudioPlayer.playOrPause();
  }

  Future<void> play() async {
    await assetsAudioPlayer.play();
  }

  Future<void> pause() async {
    await assetsAudioPlayer.pause();
  }

  Future<void> stop() async {
    await assetsAudioPlayer.stop();
  }

  Future<void> next() async {
    await assetsAudioPlayer.next();
  }

  Future<void> prev() async {
    await assetsAudioPlayer.previous();
  }
}
