import 'dart:async';
import 'dart:convert';

import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:marquee/marquee.dart';
import 'package:music/components/blurBackground.dart';
import 'package:music/database/lyricDataBase.dart';
import 'package:music/lyric/lyric.dart';
import 'package:music/model/currentSong.dart';
import 'package:music/page/painter.dart';
import 'package:music/plugin/audio.dart';
import 'package:music/settings/dio_setting.dart';
import 'package:provider/provider.dart';
import '../plugin/duration.dart';
import '../json_convert/songs.dart';
import 'dart:ui' as ui;

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
          defaultTextColor: Color(0xFFFFFFFF),
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

class __PageState extends State<_Page> with TickerProviderStateMixin {
  StreamSubscription onReadyToPlay;
  StreamSubscription currentPosition, musicInfo;
  String totalDuration = '0.00';
  String currentDuration = '0.00';
  double totalSeconds = 238.0;
  double currentSeconds = 0.0;
  int playIndex = 0;
  bool _showLyric = false;
  AnimationController controller, _waveController;
  LyricContent lyricContent;
  Animation animation;
  @override
  void initState() {
    onReadyToPlay =
        AudioInstance().assetsAudioPlayer.onReadyToPlay.listen((event) {
      if (event != null && event.duration != null) {
        setState(() {
          totalDuration = event.duration.mmSSFormat;
          totalSeconds = event.duration.inSeconds.toDouble();
        });
      }
    });
    currentPosition =
        AudioInstance().assetsAudioPlayer.currentPosition.listen((event) {
      if (event != null) {}
      setState(() {
        currentDuration = "${event.mmSSFormat}";
        currentSeconds = event.inSeconds.toDouble();
      });
    });
    musicInfo = AudioInstance()
        .assetsAudioPlayer
        .realtimePlayingInfos
        .listen((RealtimePlayingInfos event) {
      if (event.current != null && event.current.index != null) {
        if (playIndex != event.current.index) {
          playIndex = event.current.index;
          context.read<CurrentSong>().setSong(
              context.read<CurrentSong>().tempPlayList[event.current.index]);
          _getSonglyric();
        }
      }
    });
    controller =
        new AnimationController(vsync: this, duration: Duration(seconds: 15));
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _getSonglyric();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _waveController.dispose();
    onReadyToPlay.cancel();
    currentPosition.cancel();
    musicInfo.cancel();
    super.dispose();
  }

  void _getSonglyric() async {
    lyricContent = null;
    final cid = context.read<CurrentSong>().song.cid;
    List<LyricDBInfoMation> lyricList =
        await LyricDataBaseProvider.db.queryLyricWithcId(cid);
    if (lyricList.length > 0) {
      lyricContent = LyricContent.from(lyricList[0].lyric);
       setState(() {});
    } else {
      try {
        Response response = await Dio(dioOptions).get(
            "http://api.migu.jsososo.com/lyric",
            queryParameters: {'cid': cid});
        Map songsMap = json.decode(response.toString());
        if (songsMap['result'] == 100) {
          lyricContent = LyricContent.from(songsMap['data']);
          await LyricDataBaseProvider.db
              .insetDB(cId: cid, lyric: songsMap['data']);
          setState(() {});
        } else {
          print('error');
        }
      } catch (e) {
        print('error');
      }
    }
  }

  Widget _buildLyric(BuildContext context) {
    TextStyle style = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(height: 2, fontSize: 16, color: Colors.white);
    if (lyricContent != null && lyricContent.size > 0) {
      return LayoutBuilder(builder: (context, constraints) {
        final normalStyle = style.copyWith(color: style.color.withOpacity(0.7));
        //歌词顶部与尾部半透明显示
        return ShaderMask(
          shaderCallback: (rect) {
            return ui.Gradient.linear(Offset(rect.width / 2, 0),
                Offset(rect.width / 2, constraints.maxHeight), [
              const Color(0x00FFFFFF),
              style.color,
              style.color,
              const Color(0x00FFFFFF),
            ], [
              0.0,
              0.15,
              0.85,
              1
            ]);
          },
          child: StreamBuilder(
              stream: AudioInstance().assetsAudioPlayer.isPlaying,
              builder: (context, snapshot) {
                bool isPlaying = snapshot.data;
                if (snapshot.data == null) {
                  isPlaying = false;
                }
                if (isPlaying) {
                  controller.repeat();
                  _waveController.repeat();
                } else {
                  controller.stop();
                  _waveController.stop();
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Lyric(
                    id: context.watch<CurrentSong>().song.id,
                    lyric: lyricContent,
                    lyricLineStyle: normalStyle,
                    highlight: style.color,
                    position: currentSeconds.floor() * 1000,
                    onTap: _setLyricState,
                    size: Size(
                        constraints.maxWidth,
                        constraints.maxHeight == double.infinity
                            ? 0
                            : constraints.maxHeight),
                    playing: isPlaying,
                  ),
                );
              }),
        );
      });
    } else {
      return Container(
        child: Center(
          child: Text('暂无歌词', style: style),
        ),
      );
    }
  }

  Widget _buildCenterSection(context) {
    return Expanded(
        child: AnimatedCrossFade(
            crossFadeState: _showLyric
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            layoutBuilder: (Widget topChild, Key topChildKey,
                Widget bottomChild, Key bottomChildKey) {
              return Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Center(
                    key: bottomChildKey,
                    child: bottomChild,
                  ),
                  Center(
                    key: topChildKey,
                    child: topChild,
                  ),
                ],
              );
            },
            firstChild: _buildImage(context),
            secondChild: _buildLyric(context),
            duration: Duration(milliseconds: 300)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: NeumorphicBackground(
          child: Stack(
            children: <Widget>[
              BlurBackground(
                  imageUrl: context.watch<CurrentSong>().song.album.picUrl),
              Column(
                children: <Widget>[
                  SizedBox(height: 14),
                  _buildTopBar(context),
                  SizedBox(height: 80),
                  _buildCenterSection(context),
                  SizedBox(height: 10),
                  _buildTitle(context),
                  SizedBox(height: 10),
                  _buildSeekBar(context),
                  SizedBox(height: 30),
                  _buildControlsBar(context),
                  SizedBox(height: 30),
                ],
              ),
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
            child: IconButton(
              padding: const EdgeInsets.all(18.0),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.navigate_before,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    double expandedSize = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CustomPaint(
              painter:
                  RingOfCirclesPainter(Colors.white, _waveController.value),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(-controller.value * 2 * pi),
                child: GestureDetector(
                  onTap: _setLyricState,
                  child: Container(
                      width: expandedSize * 0.8,
                      height: expandedSize * 0.8,
                      child: new Center(
                          child: Container(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Provider.of<CurrentSong>(context)
                                      .song
                                      .album
                                      .picUrl !=
                                  null
                              ? new CachedNetworkImage(
                                  imageUrl: Provider.of<CurrentSong>(context)
                                      .song
                                      .album
                                      .picUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      new Image.asset(
                                    'assets/music2.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : new Image.asset(
                                  'assets/music2.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ))),
                ),
              ),
            ),
          ],
        );
      },
      child: Neumorphic(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Provider.of<CurrentSong>(context).song.name.length > 20
            ? ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                    maxHeight: 50),
                child: Marquee(
                  text: Provider.of<CurrentSong>(context).song.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: NeumorphicTheme.defaultTextColor(context)),
                  pauseAfterRound: Duration(seconds: 3),
                  blankSpace: 100.0,
                  accelerationDuration: Duration(seconds: 3),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: Duration(seconds: 3),
                  decelerationCurve: Curves.linear,
                ),
              )
            : Text(Provider.of<CurrentSong>(context).song.name,
                softWrap: false,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: NeumorphicTheme.defaultTextColor(context))),
        Text(Provider.of<CurrentSong>(context).song.artists[0].name,
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
            onChanged: (value) {
              int flooredValue = value.floor();
              int hour = (flooredValue / 3600).floor();
              int min = (flooredValue / 60).floor();
              int sec = (flooredValue % 60).floor();
              AudioInstance()
                  .seek(Duration(minutes: min, seconds: sec, hours: hour));
            },
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
                      context.read<CurrentSong>().tempPlayList[AudioInstance()
                          .assetsAudioPlayer
                          .readingPlaylist
                          .currentIndex]),
                  _getSonglyric()
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
                bool isPlaying = snapshot.data;
                if (snapshot.data == null) {
                  isPlaying = false;
                }
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
                      context.read<CurrentSong>().tempPlayList[AudioInstance()
                          .assetsAudioPlayer
                          .readingPlaylist
                          .currentIndex]),
                  _getSonglyric()
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

  void _setLyricState() {
    setState(() {
      _showLyric = !_showLyric;
    });
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
