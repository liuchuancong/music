import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/components/main_list_item.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/database/downloadMusicDatabase.dart';
import 'package:music/database/playListDataBase.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/plugin/audio.dart';

class LocalMusicPage extends StatefulWidget {
  @override
  _LocalMusicPageState createState() => _LocalMusicPageState();
}

class _LocalMusicPageState extends State<LocalMusicPage> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF3E3E3E),
          baseColor: Colors.black,
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
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  List<Widget> playList = [];
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.navigate_before,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )),
          Align(
            alignment: Alignment.center,
            child: Text(
              '本地音乐',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: NeumorphicButton(
                padding: const EdgeInsets.all(10.0),
                onPressed: () {
                  // _playAllMusic();
                },
                style: NeumorphicStyle(
                    color: Colors.white,
                    shape: NeumorphicShape.flat,
                    depth: 0,
                    intensity: 1,
                    boxShape: NeumorphicBoxShape.stadium()),
                child: Text('全部播放')),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getLocalMusics();
  }

  _getLocalMusics() async {
    String musicPath = await AndroidPathProvider.musicPath;
    String _localPath = musicPath + Platform.pathSeparator + 'Downloads';

    final List<DwonloadDBInfoMation> _playList =
        await DataBaseDownLoadListProvider.db.queryAll();
    var tempList = _playList.map((music) {
      Map songsMap = json.decode(music.song);
      SongList song = new SongList.fromJson(songsMap);
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: MainListItem(
            context: context,
            onTap: () {
              AudioInstance().initFileAudio(
                  _localPath + Platform.pathSeparator + song.name, song);
            },
            song: song,
            trailingTap: () {},
          ));
    }).toList();

    setState(() {
      playList = tempList;
    });
  }

  Future _showDeleteDialog(PlayListDBInfoMation menu) async {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: Container(
        child: Column(
          children: <Widget>[
            SimpleListTile(
              title: '确定删除该歌单吗?',
              onTap: null,
            ),
            Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              SizedBox(
                width: 60,
                child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('取消')),
              ),
              SizedBox(
                width: 60,
                child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('确定')),
              ),
            ]))
          ],
        ),
      ),
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
    return Scaffold(
      body: SafeArea(
        child: NeumorphicBackground(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              Expanded(
                  child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  //设置四周圆角 角度
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                ),
                child: ListView(
                  children:
                      ListTile.divideTiles(tiles: playList, context: context)
                          .toList(),
                ),
              ))
            ],
          ),
        ),
      ),
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
