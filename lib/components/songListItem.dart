import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/json_convert/songs.dart';
import 'package:music/model/currentSong.dart';
import 'package:provider/provider.dart';

class SongListItem extends StatelessWidget {
  final SongList song;
  final Function onPressed;
  const SongListItem({Key key, this.song, this.onPressed}) : super(key: key);
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
                leading: Container(
                  width: 60,
                  height: 60,
                  child: song.album.picUrl != null
                      ? new CachedNetworkImage(
                          imageUrl: song.album.picUrl,
                          errorWidget: (context, url, error) =>
                                      new Image.asset(
                                    'assets/music2.jpg',
                                    fit: BoxFit.cover,
                                  ),
                        )
                      : new Image.asset('assets/music2.jpg', fit: BoxFit.cover),
                ),
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
                trailing: IconButton(
                    icon: new Icon(Icons.more_vert), onPressed: onPressed),
                onTap: null),
          ),
        ),
        SizedBox(
          height: Provider.of<CurrentSong>(context)
                      .tempPlayList[
                          Provider.of<CurrentSong>(context).tempPlayList.length - 1]
                      .id ==
                  song.id
              ? 70
              : 10,
        ),
      ],
    );
  }
}

class SongListTile extends StatelessWidget {
  final SongList song;

  const SongListTile({Key key, this.song}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          elevation: 0.0,
          borderRadius: new BorderRadius.all(Radius.circular(15.0)),
          child: Container(
            padding: const EdgeInsets.all(6.0),
            child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  child: song.album.picUrl != null
                      ? new CachedNetworkImage(
                          imageUrl: song.album.picUrl,
                          errorWidget: (context, url, error) =>
                                      new Image.asset(
                                    'assets/music2.jpg',
                                    fit: BoxFit.cover,
                                  ),
                        )
                      : new Image.asset('assets/music1.jpeg'),
                ),
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
      ],
    );
  }
}

class SimpleListTile extends StatelessWidget {
  final String title;
  final Function onTap;
  final Widget leading;
  final Widget trailing;

  const SimpleListTile(
      {Key key, this.title, this.onTap, this.leading, this.trailing})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Container(
            width: 50,
            child: new Text(
              title,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: leading == null ? null : leading,
          trailing: trailing == null ? null : trailing,
          onTap: onTap,
        ),
      ],
    );
  }
}
