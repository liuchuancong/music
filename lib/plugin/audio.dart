import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music/json_convert/songs.dart';

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
      assetsAudioPlayer.open(Playlist(audios: playList),
          loopMode: LoopMode.playlist, showNotification: true);
    } catch (t) {
      //mp3 unreachable
    }
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
