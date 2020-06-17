import 'package:assets_audio_player/assets_audio_player.dart';

class AudioInstance {
  // 单例公开访问点
  factory AudioInstance() => _getInstance();

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

  Future<void> initAudio(uri) async {
    try {
      await assetsAudioPlayer.open(
        Audio.network(uri),
      );
    } catch (t) {
      //mp3 unreachable
    }
  }

  Future<void> playOrPause() async {
    await assetsAudioPlayer.playOrPause();
    print('playOrPause');
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
}
