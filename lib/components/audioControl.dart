import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/page/audio_player_page.dart';
import 'package:music/plugin/audio.dart';
import '../plugin/duration.dart';
import '../json_convert/songs.dart';

class MyPageWithAudio extends StatefulWidget {
  final SongList currentPlay;

  const MyPageWithAudio({Key key, this.currentPlay}) : super(key: key);
  @override
  _MyPageWithAudioState createState() => _MyPageWithAudioState();
}

class _MyPageWithAudioState extends State<MyPageWithAudio> {
  bool _play = false;
  String _currentPosition = "";
  StreamSubscription onReadyToPlay;
  StreamSubscription currentPosition;
  String totalDuration;
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
    super.initState();
  }

  @override
  void dispose() {
    onReadyToPlay.cancel();
    currentPosition.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: Hero(
        tag: widget.currentPlay.id,
        child: widget.currentPlay.album.picUrl != null
            ? new Image.network(widget.currentPlay.album.picUrl)
            : new Image.asset('assets/notFound.jpeg'),
      ),
      title: new Text(
        widget.currentPlay.name,
        softWrap: false,
      ),
      subtitle: Column(
        children: [
          new Text(widget.currentPlay.artists[0].name),
          Text(_currentPosition)
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      trailing: Wrap(
        spacing: 12, // space between two icons
        children: <Widget>[
          NeumorphicButton(
            onPressed: () {},
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
              setState(() {
                _play = !_play;
              });
              AudioInstance().playOrPause();
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: Icon(
              _play ? Icons.play_arrow : Icons.pause,
              size: 20,
              color: _iconsColor(),
            ),
          ),
          NeumorphicButton(
            onPressed: () {},
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
            child: AudioPlayerPage(currentPlay: widget.currentPlay),
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
