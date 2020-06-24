import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music/common/bottomSheet.dart';
import 'package:music/common/common.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/database/playListDataBase.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/model/currentSong.dart';
import 'package:music/plugin/audio.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'database/musicMenuDatabas.dart';

class MainMethod {
  Future showBottomSheet(
      {@required SongList song, @required BuildContext context}) async {
    List<MusicDBInfoMation> list =
        await DataBaseMusicProvider.db.queryMusicWithMusicId(song.id);
    final List<PlayListDBInfoMation> playList =
        await DataBasePlayListProvider.db.queryAll();
    await BottomSheetManage().showBottomSheet(
      song,
      context,
      [
        SongListTile(song: song),
        SimpleListTile(
          title: '下一首播放',
          onTap: () {
            payMusicBeNext(song: song, context: context);
          },
        ),
        SimpleListTile(
          title: '添加到我的歌单',
          onTap: () {
            showMusicMenu(context, song, playList);
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

  void payMusicBeNext(
      {@required SongList song, @required BuildContext context}) {
    if (context.read<CurrentSong>().tempPlayList.length == 0) {
      List<SongList> _tempPlayList = [];
      _tempPlayList.add(song);
      AudioInstance().initAudioList(_tempPlayList).then((value) => {
            context.read<CurrentSong>().settempPlayList(_tempPlayList),
            context.read<CurrentSong>().setSong(song)
          });
    } else {
      int currentIndex = context
          .read<CurrentSong>()
          .tempPlayList
          .indexOf(context.read<CurrentSong>().song);
      int songInListIndex =
          context.read<CurrentSong>().tempPlayList.indexOf(song);
      if (currentIndex != -1 && currentIndex == songInListIndex) {
        Navigator.pop(context);
        return;
      }
      if (songInListIndex != -1) {
        context.read<CurrentSong>().removeAtIndex(songInListIndex);
        AudioInstance().reMoveAtIndex(songInListIndex);
      }
      if (currentIndex != -1) {
        context.read<CurrentSong>().insertTempPlatList(currentIndex + 1, song);
        AudioInstance().insetAtIndex(currentIndex + 1, song);
      }
    }
    Navigator.pop(context);
  }

  Future addMusicInsertDataBase(
      {PlayListDBInfoMation menu, SongList song}) async {
    bool hasSaved =
        await MusicMenuDatabaseInstance(menu.id.toString()).hasSaved(song.id);
    if (!hasSaved) {
      MusicMenuDatabaseInstance(menu.id.toString())
          .insetDB(song: jsonEncode(song), songId: song.id);
    } else {
      Fluttertoast.showToast(
        msg: "已经添加过了哦~",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
    }
  }

  showMusicMenu(BuildContext context, SongList song,
      List<PlayListDBInfoMation> playList) async {
    Navigator.of(context).pop();
    var tempList = playList
        .map((menu) => Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SimpleListTile(
                title: menu.menuName,
                leading: Container(
                    width: 60,
                    height: 60,
                    child: new Image.memory(base64Decode(menu.menuCover),fit: BoxFit.cover,)),
                trailing: null,
                onTap: () {
                  Navigator.of(context).pop();
                  addMusicInsertDataBase(menu: menu, song: song);
                },
              ),
            ))
        .toList();
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints.loose(
              Size(double.infinity, MediaQuery.of(context).size.height / 2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SimpleListTile(
                title: '我的歌单',
                onTap: null,
              ),
              Expanded(
                child: new SingleChildScrollView(
                  child: ListBody(
                    children: tempList,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )..show();
  }
}
