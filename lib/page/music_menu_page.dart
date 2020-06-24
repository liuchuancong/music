import 'dart:convert';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/common/bottomSheet.dart';
import 'package:music/common/common.dart';
import 'package:music/components/audioControl.dart';
import 'package:music/components/main_list_item.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/database/database.dart';
import 'package:music/database/musicMenuDatabas.dart';
import 'package:music/database/playListDataBase.dart';
import 'package:music/main_method.dart';
import 'package:provider/provider.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/model/currentSong.dart';
import 'package:music/plugin/audio.dart';

class MusicMenuPage extends StatefulWidget {
  final int id;

  const MusicMenuPage({Key key, @required this.id}) : super(key: key);
  @override
  _MusicMenuPageState createState() => _MusicMenuPageState();
}

class _MusicMenuPageState extends State<MusicMenuPage> {
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
        child: _Page(
          id: widget.id,
        ));
  }
}

class _Page extends StatefulWidget {
  final int id;

  const _Page({Key key, this.id}) : super(key: key);
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  List<Widget> playList = [];
  List<MusicMenu> allMusicFiles = [];
  PlayListDBInfoMation playMenuInfo = new PlayListDBInfoMation(menuName: '');
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
            child: Container(
              width: 200,
              child: Center(
                child: Text(
                  playMenuInfo.menuName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
              ),
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
    _getMenuMusics();
    _getMenuInfo();
  }

  Future showBottomSheet(
      {@required SongList song, @required BuildContext context}) async {
    List<MusicDBInfoMation> list =
        await DataBaseMusicProvider.db.queryMusicWithMusicId(song.id);
    await BottomSheetManage().showBottomSheet(
      song,
      context,
      [
        SongListTile(song: song),
        SimpleListTile(
          title: '下一首播放',
          onTap: () {
            MainMethod().payMusicBeNext(song: song, context: context);
          },
        ),
        SimpleListTile(
          title: '删除',
          onTap: () {
            MusicMenuDatabaseInstance(widget.id.toString())
                .deleteMenuWithId(song.id);
            Navigator.pop(context);
            _getMenuMusics();
          },
        ),
        SimpleListTile(
          title: list.length > 0 ? '已下载' : '下载',
          onTap: list.length > 0
              ? () {
                  Navigator.pop(context);
                }
              : () {
                  DialogManage().downLoad(song: song, context: context);
                },
        ),
      ],
    );
  }

  void _payMusic(SongList song) {
    context.read<CurrentSong>().setSong(song);
    context.read<CurrentSong>().settempPlayList([song]);
    AudioInstance().initAudio(song);
  }

  _playAllMusic() async {
    if (allMusicFiles.length == 0) return;
    final Playlist playlist = new Playlist();
    final List<SongList> tempListArr = [];
    allMusicFiles.forEach((music) {
      Map songsMap = json.decode(music.song);
      SongList song = new SongList.fromJson(songsMap);
      tempListArr.add(song);
      playlist.add(new Audio.network(
        song.url,
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

  _getMenuInfo() async {
    final PlayListDBInfoMation _menuInfo =
        await DataBasePlayListProvider.db.getMenuWithId(widget.id);
    setState(() {
      playMenuInfo = _menuInfo;
    });
  }

  _getMenuMusics() async {
    print(widget.id.toString());
    final List<MusicMenu> _playList =
        await MusicMenuDatabaseInstance(widget.id.toString()).queryAll();
    print(_playList.length);
    allMusicFiles = _playList;
    var tempList = _playList.map((music) {
      Map songsMap = json.decode(music.song);
      SongList song = new SongList.fromJson(songsMap);
      return Container(
          child: MainListItem(
        context: context,
        icon: Icons.more_vert,
        onTap: () {
          _payMusic(song);
        },
        song: song,
        trailingTap: () {
          showBottomSheet(song: song, context: context);
        },
      ));
    }).toList();

    setState(() {
      playList = tempList;
    });
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
