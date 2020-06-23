import 'package:flutter/material.dart';
import 'package:music/common/bottomSheet.dart';
import 'package:music/common/common.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/model/currentSong.dart';
import 'package:music/plugin/audio.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';

class MainMethod{
   Future showBottomSheet({@required SongList song,@required BuildContext context}) async {
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
            payMusicBeNext(song:song,context: context);
          },
        ),
        SimpleListTile(
          title: '添加到我喜欢的',
          onTap: () {},
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
    void payMusicBeNext({@required SongList song,@required BuildContext context}) {
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
}