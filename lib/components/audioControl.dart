import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/model/currentSong.dart';
import 'package:music/page/audio_player_page.dart';
import 'package:music/plugin/audio.dart';
import 'package:provider/provider.dart';
import '../plugin/duration.dart';
import '../json_convert/songs.dart';

class MyPageWithAudio extends StatefulWidget {
  final SongList currentPlay;

  const MyPageWithAudio({Key key, this.currentPlay}) : super(key: key);
  @override
  _MyPageWithAudioState createState() => _MyPageWithAudioState();
}

class _MyPageWithAudioState extends State<MyPageWithAudio> {
  String _currentPosition = "";
  StreamSubscription onReadyToPlay;
  StreamSubscription currentPosition;
  StreamSubscription musicInfo;
  String totalDuration;
  int playIndex = 0;
  @override
  void initState() {
    onReadyToPlay =
        AudioInstance().assetsAudioPlayer.onReadyToPlay.listen((event) {
      setState(() {
        _currentPosition =
            "${Duration().mmSSFormat} / ${event.duration.mmSSFormat}";
        totalDuration = event.duration.mmSSFormat;
      });
    });
    currentPosition =
        AudioInstance().assetsAudioPlayer.currentPosition.listen((event) {
      setState(() {
        _currentPosition = "${event.mmSSFormat} / $totalDuration";
      });
    });
    musicInfo = AudioInstance()
        .assetsAudioPlayer
        .realtimePlayingInfos
        .listen((RealtimePlayingInfos event) {
      if (playIndex != event.current.index) {
        playIndex = event.current.index;
        context
            .read<CurrentSong>()
            .setSong(context.read<CurrentSong>().playList[event.current.index]);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    onReadyToPlay.cancel();
    currentPosition.cancel();
    musicInfo.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: Hero(
        tag: Provider.of<CurrentSong>(context).song.id,
        child: Provider.of<CurrentSong>(context).song.album.picUrl != null
            ? new Image.network(
                Provider.of<CurrentSong>(context).song.album.picUrl)
            : new Image.asset('assets/notFound.jpeg'),
      ),
      title: new Text(
        Provider.of<CurrentSong>(context).song.name,
        softWrap: false,
      ),
      subtitle: Column(
        children: [
          new Text(Provider.of<CurrentSong>(context).song.artists[0].name),
          Text(_currentPosition)
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      trailing: Wrap(
        spacing: 12, // space between two icons
        children: <Widget>[
          NeumorphicButton(
            onPressed: () {
              AudioInstance().prev().then((value) => {
                    print(AudioInstance()
                        .assetsAudioPlayer
                        .readingPlaylist
                        .currentIndex),
                    context.read<CurrentSong>().setSong(
                        context.read<CurrentSong>().playList[AudioInstance()
                            .assetsAudioPlayer
                            .readingPlaylist
                            .currentIndex])
                  });
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: Icon(
              Icons.skip_previous,
              size: 20,
              color: _iconsColor(),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              AudioInstance().playOrPause();
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: StreamBuilder(
                stream: AudioInstance().assetsAudioPlayer.isPlaying,
                builder: (context, snapshot) {
                  final bool isPlaying = snapshot.data;
                  return Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20,
                    color: _iconsColor(),
                  );
                }),
          ),
          NeumorphicButton(
            onPressed: () {
              AudioInstance().next().then((value) => {
                    context.read<CurrentSong>().setSong(
                        context.read<CurrentSong>().playList[AudioInstance()
                            .assetsAudioPlayer
                            .readingPlaylist
                            .currentIndex])
                  });
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: Icon(
              Icons.skip_next,
              size: 20,
              color: _iconsColor(),
            ),
          ), // icon-2
        ],
      ),
      onTap: () {
        //打开B路由
        Navigator.push(context, PageRouteBuilder(pageBuilder:
            (BuildContext context, Animation animation,
                Animation secondaryAnimation) {
          return new FadeTransition(
            opacity: animation,
            child: AudioPlayerPage(
                currentPlay: Provider.of<CurrentSong>(context).song),
          );
        }));
      },
    );
  }

  Color _iconsColor() {
    final theme = NeumorphicTheme.of(context);
    if (theme.isUsingDark) {
      return theme.current.accentColor;
    } else {
      return null;
    }
  }
}
