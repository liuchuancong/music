import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:music/class/song.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/plugin/download.dart';

class DialogManage {
  downLoad({SongList song, BuildContext context}) async {
    Navigator.pop(context);
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: Container(
        child: Column(
          children: <Widget>[
            SongListTile(song: song),
            SimpleListTile(
              title: '标准品质_128Kbps',
              onTap: () {
                Navigator.pop(context);
                DownLoadInstance().getSongInfo(song, SongType.normal);
              },
            ),
            SimpleListTile(
              title: 'HQ高品质_320Kbps',
              onTap: () {
                Navigator.pop(context);
                DownLoadInstance().getSongInfo(song, SongType.high);
              },
            ),
            SimpleListTile(
              title: 'SQ无损品质_flac',
              onTap: () {
                Navigator.pop(context);
                DownLoadInstance().getSongInfo(song, SongType.undamaged);
              },
            ),
          ],
        ),
      ),
    )..show();
  }
}
