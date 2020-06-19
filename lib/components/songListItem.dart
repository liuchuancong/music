import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/model/currentSong.dart';
import 'package:provider/provider.dart';

class SongListItem extends StatelessWidget {
  final SongList song;

  const SongListItem({Key key, this.song}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          elevation: 5,
          borderRadius: new BorderRadius.all(Radius.circular(15.0)),
          child: Container(
            padding: const EdgeInsets.all(6.0),
            child: ListTile(
                leading: song.album.picUrl != null
                    ? new Image.network(
                        song.album.picUrl,
                      )
                    : new Image.asset('assets/notFound.jpeg'),
                title: new Text(
                  song.name,
                  softWrap: false,
                ),
                subtitle: Column(
                  children: [
                    new Text(
                      song.artists[0].name,
                      softWrap: false,
                    ),
                    new Text(
                      '',
                      softWrap: false,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                onTap: null),
          ),
        ),
        SizedBox(
          height: Provider.of<CurrentSong>(context)
                      .playList[
                          Provider.of<CurrentSong>(context).playList.length - 1]
                      .id ==
                  song.id
              ? 70
              : 10,
        ),
      ],
    );
  }
}
