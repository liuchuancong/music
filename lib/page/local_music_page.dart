import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/components/audioControl.dart';
import 'package:music/components/main_list_item.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/database/database.dart';
import 'package:music/database/downloadMusicDatabase.dart';
import 'package:music/plugin/download.dart';
import 'package:provider/provider.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/model/currentSong.dart';
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
          baseColor: Color(0xFFFFFFFF),
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
  List<DwonloadDBInfoMation> allLocalFiles = [];
  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
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
                  _playAllMusic();
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

  _playAllMusic() async {
    if (allLocalFiles.length == 0) return;
    String _musicPath = await AndroidPathProvider.musicPath;
    String _localPath = _musicPath + Platform.pathSeparator + 'Downloads';
    final Playlist playlist = new Playlist();
    final List<SongList> tempListArr = [];
    allLocalFiles.forEach((music) {
      Map songsMap = json.decode(music.song);
      SongList song = new SongList.fromJson(songsMap);
      tempListArr.add(song);
      final path = _localPath + Platform.pathSeparator + music.songFileName;
      playlist.add(new Audio.file(
        path,
        metas: Metas(
          title: song.name,
          artist: song.artists[0].name,
          album: song.album.name,
          image: MetasImage.network(
            song.album.picUrl,
          ), //can be MetasImage.network
        ),
      ));
    });
    AudioInstance().initPlaylist(playlist).then((value) => {
          context.read<CurrentSong>().settempPlayList(tempListArr),
          context.read<CurrentSong>().setSong(tempListArr[0])
        });
  }

  void _playLocalFile(DwonloadDBInfoMation music) async {
    String _musicPath = await AndroidPathProvider.musicPath;
    String _localPath = _musicPath + Platform.pathSeparator + 'Downloads';
    Map songsMap = json.decode(music.song);
    SongList song = new SongList.fromJson(songsMap);
    context.read<CurrentSong>().setSong(song);
    context.read<CurrentSong>().settempPlayList([song]);
    AudioInstance().initFileAudio(
        _localPath + Platform.pathSeparator + music.songFileName, song);
  }

  _deleteLocalFile(DwonloadDBInfoMation music) async {
    if (music.songId != null &&
        context.read<CurrentSong>().song != null &&
        context.read<CurrentSong>().song.id != null) {
      if (context.read<CurrentSong>().song.id == music.songId) {
        AudioInstance().stop();
        context.read<CurrentSong>().setSong(null);
        context.read<CurrentSong>().settempPlayList([]);
      }
    }
    await DataBaseDownLoadListProvider.db.deleteSongWithId(music.id);
    await DownLoadInstance().delete(music.taskId);
    await DataBaseMusicProvider.db.deleteMusicWithId(music.songId);
    _getLocalMusics();
  }

  _getLocalMusics() async {
    final List<DwonloadDBInfoMation> _playList =
        await DataBaseDownLoadListProvider.db.queryAll();
    allLocalFiles = _playList;
    var tempList = _playList.map((music) {
      Map songsMap = json.decode(music.song);
      SongList song = new SongList.fromJson(songsMap);
      return Container(
          child: MainListItem(
            context: context,
            icon: Icons.delete_outline,
            onTap: () {
              _playLocalFile(music);
            },
            song: song,
            trailingTap: () {
              _showDeleteDialog(music);
            },
          ));
    }).toList();

    setState(() {
      playList = tempList;
    });
  }

  Future _showDeleteDialog(DwonloadDBInfoMation music) async {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: Container(
        child: Column(
          children: <Widget>[
            SimpleListTile(
              title: '确定删除该歌曲吗?',
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
                      _deleteLocalFile(music);
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
    return Scaffold(
      body: SafeArea(
        child: NeumorphicBackground(
          backendColor: Colors.red,
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              Expanded(
                  child: Container(
                decoration: new BoxDecoration(
                  color: Colors.black,
                ),
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
                ),
              )),
              context.watch<CurrentSong>().song != null
                  ? MyPageWithAudio()
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
