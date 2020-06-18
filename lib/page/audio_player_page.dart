import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/model/currentSong.dart';
import 'package:music/plugin/audio.dart';
import 'package:provider/provider.dart';
import '../plugin/duration.dart';
import '../json_convert/songs.dart';

class AudioPlayerPage extends StatefulWidget {
  final SongList currentPlay;

  const AudioPlayerPage({Key key, this.currentPlay}) : super(key: key);
  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF3E3E3E),
          baseColor: Color(0xFFDDE6E8),
          intensity: 0.5,
          lightSource: LightSource.topLeft,
          depth: 10,
        ),
        darkTheme: neumorphicDefaultDarkTheme.copyWith(
            defaultTextColor: Colors.white70),
        child: _Page());
  }
}

class _Page extends StatefulWidget {
  const _Page({Key key}) : super(key: key);
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  bool _useDark = false;
  StreamSubscription onReadyToPlay;
  StreamSubscription currentPosition, musicInfo;
  String totalDuration = '0.00';
  String currentDuration = '0.00';
  double totalSeconds = 0.0;
  double currentSeconds = 0.0;
  int playIndex = 0;
  @override
  void initState() {
    onReadyToPlay =
        AudioInstance().assetsAudioPlayer.onReadyToPlay.listen((event) {
      setState(() {
        totalDuration = event.duration.mmSSFormat;
        totalSeconds = event.duration.inSeconds.toDouble();
      });
    });
    currentPosition =
        AudioInstance().assetsAudioPlayer.currentPosition.listen((event) {
      setState(() {
        currentDuration = "${event.mmSSFormat}";
        currentSeconds = event.inSeconds.toDouble();
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
    return Scaffold(
      body: SafeArea(
        child: NeumorphicBackground(
          child: Column(
            children: <Widget>[
              SizedBox(height: 14),
              _buildTopBar(context),
              SizedBox(height: 80),
              _buildImage(context),
              SizedBox(height: 30),
              _buildTitle(context),
              SizedBox(height: 30),
              _buildSeekBar(context),
              SizedBox(height: 30),
              _buildControlsBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: NeumorphicButton(
              padding: const EdgeInsets.all(18.0),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              child: Icon(
                Icons.navigate_before,
                color: _iconsColor(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              Provider.of<CurrentSong>(context).song.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(color: NeumorphicTheme.defaultTextColor(context)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: NeumorphicButton(
              padding: const EdgeInsets.all(18.0),
              onPressed: () {
                setState(() {
                  _useDark = !_useDark;
                  NeumorphicTheme.of(context).themeMode =
                      _useDark ? ThemeMode.dark : ThemeMode.light;
                });
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              child: Icon(
                Icons.favorite_border,
                color: _iconsColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: Hero(
        tag: Provider.of<CurrentSong>(context).song.id,
        child: Container(
            height: 200,
            width: 200,
            child: Image.network(
              Provider.of<CurrentSong>(context).song.album.picUrl,
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text("Blinding Lights",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 34,
                color: NeumorphicTheme.defaultTextColor(context))),
        const SizedBox(
          height: 4,
        ),
        Text("The Weeknd",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: NeumorphicTheme.defaultTextColor(context))),
      ],
    );
  }

  Widget _buildSeekBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentDuration,
                    style: TextStyle(
                        color: NeumorphicTheme.defaultTextColor(context)),
                  )),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    totalDuration,
                    style: TextStyle(
                        color: NeumorphicTheme.defaultTextColor(context)),
                  )),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          NeumorphicSlider(
            height: 8.0,
            min: 0.0,
            max: totalSeconds,
            value: currentSeconds,
          )
        ],
      ),
    );
  }

  Widget _buildControlsBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        NeumorphicButton(
          padding: const EdgeInsets.all(18.0),
          onPressed: () {
            AudioInstance().prev().then((value) => {
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
            color: _iconsColor(),
          ),
        ),
        const SizedBox(width: 12),
        NeumorphicButton(
          padding: const EdgeInsets.all(24.0),
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
                  size: 42,
                  color: _iconsColor(),
                );
              }),
        ),
        const SizedBox(width: 12),
        NeumorphicButton(
          padding: const EdgeInsets.all(18.0),
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
            color: _iconsColor(),
          ),
        ),
      ],
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
