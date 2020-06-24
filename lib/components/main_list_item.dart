import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music/json_convert/songs.dart';

class MainListItem extends StatelessWidget {
  final BuildContext context;
  final SongList song;
  final Function onTap;
  final Function trailingTap;
  final IconData icon;
  const MainListItem(
      {Key key,
      @required this.context,
      @required this.song,
      @required this.onTap,
      @required this.trailingTap,
      @required this.icon})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          child: song.album.picUrl != null
              ? new CachedNetworkImage(
                  imageUrl: song.album.picUrl,
                  errorWidget: (context, url, error) =>
                      new Image.asset('assets/music1.jpg', fit: BoxFit.cover))
              : new Image.asset('assets/music1.jpg', fit: BoxFit.cover),
        ),
        title: new Text(
          song.name,
          softWrap: false,
        ),
        subtitle: new Text(song.artists[0].name),
        trailing: IconButton(icon: new Icon(icon), onPressed: trailingTap),
        onTap: onTap,
      ),
    );
  }
}
