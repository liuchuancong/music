import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flashy_tab_bar/flashy_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/common/bottomSheet.dart';
import 'package:music/components/audioControl.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/components/taskListItem.dart';
import 'package:music/database/database.dart';
import 'package:music/json_convert/downLoadInfo.dart';
import 'package:music/json_convert/songs.dart' as songs;
import 'package:music/model/currentSong.dart';
import 'package:music/plugin/audio.dart';
import 'package:music/plugin/download.dart';
import 'package:provider/provider.dart';

class DownLoadPage extends StatefulWidget {
  @override
  _DownLoadPageState createState() => _DownLoadPageState();
}

class _DownLoadPageState extends State<DownLoadPage> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF3E3E3E),
          baseColor: Colors.white,
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
  List<Widget> tasksList = [];
  int _selectedIndex = 0;
  List<DownloadTask> tasks = [];
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: NeumorphicButton(
              padding: const EdgeInsets.all(10.0),
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
            child: Container(
              width: 150,
              child: FlashyTabBar(
                backgroundColor: Colors.white,
                animationCurve: Curves.linear,
                selectedIndex: _selectedIndex,
                showElevation: false, // use this to remove appBar's elevation
                onItemSelected: (index) => loadTasks(index),
                items: [
                  FlashyTabBarItem(
                    icon: Icon(Icons.cloud_download),
                    title: Text('下载中'),
                  ),
                  FlashyTabBarItem(
                    icon: Icon(Icons.queue_music),
                    title: Text('单曲'),
                  ),
                ],
              ),
            ),
          ),
         _selectedIndex == 1 ? Align(
            alignment: Alignment.centerRight,
            child: NeumorphicButton(
                padding: const EdgeInsets.all(10.0),
                onPressed: () {
                  _playAllMusic();
                },
                style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: 1,
                    intensity: 1,
                    boxShape: NeumorphicBoxShape.stadium()),
                child: Text('全部播放')),
          ) : Container(),
        ],
      ),
    );
  }

  _playAllMusic() {
    if (tasks.length == 0) return;
    AudioInstance().initAudioFileList(tasks).then((value) => {
          if (value.length != 0)
            {
              context.read<CurrentSong>().settempPlayList(value),
              context.read<CurrentSong>().setSong(value[AudioInstance()
                  .assetsAudioPlayer
                  .readingPlaylist
                  .currentIndex])
            }
        });
  }

  @override
  void initState() {
    loadTasks(_selectedIndex);

    super.initState();
  }

  loadTasks(int index) async {
    String query = '';
    if (index == 0) {
      query = 'SELECT * FROM task WHERE status!=3';
    } else {
      query = 'SELECT * FROM task WHERE status=3';
    }
    tasks = await FlutterDownloader.loadTasksWithRawQuery(query: query);
    tasksList = tasks
        .map((DownloadTask song) => TaskListTile(
              song: song,
              refrish: () {
                loadTasks(_selectedIndex);
              },
              onPressed: () {
                showBottomOperateSheet(song);
              },
            ))
        .toList();
    setState(() {
      _selectedIndex = index;
    });
  }

  _playFileMusic(DownloadTask song) async {
    Navigator.pop(context);
    List<MusicDBInfoMation> list =
        await DataBaseMusicProvider.db.queryMusic(song.taskId);
    if (list.length == 0) return;
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
      final tempMusic = songs.SongList(
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
      context.read<CurrentSong>().setSong(tempMusic);
      context.read<CurrentSong>().settempPlayList([tempMusic]);
      AudioInstance().initFileAudio(
          song.savedDir + Platform.pathSeparator + song.filename, tempMusic);
    }
  }

  showBottomOperateSheet(DownloadTask song) async {
    if (_selectedIndex == 0) {
      await BottomSheetManage().showDownLoadBottomSheet(
        context,
        [
          SimpleListTile(
            title: '取消下载',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().cancel(song.taskId);
            },
          ),
          SimpleListTile(
            title: '暂停下载',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().pause(song.taskId);
            },
          ),
          SimpleListTile(
            title: '恢复下载',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance()
                  .resume(song.taskId)
                  .then((value) => {loadTasks(_selectedIndex)});
            },
          ),
          SimpleListTile(
            title: '重试',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance()
                  .retry(song.taskId)
                  .then((value) => {loadTasks(_selectedIndex)});
            },
          ),
          SimpleListTile(
            title: '删除',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().remove(song.taskId);
            },
          ),
        ],
      );
    } else {
      await BottomSheetManage().showDownLoadBottomSheet(
        context,
        [
          SimpleListTile(
            title: '播放',
            onTap: () {
              _playFileMusic(song);
            },
          ),
          SimpleListTile(
            title: '删除',
            onTap: () {
              Navigator.pop(context);
              DownLoadInstance().delete(song.taskId);
              loadTasks(_selectedIndex);
            },
          ),
        ],
      );
    }
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
              SizedBox(height: 10),
              Expanded(child: ListView(children: tasksList)),
              context.watch<CurrentSong>().song != null
                  ? MyPageWithAudio()
                  : Container()
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
