import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BlurBackground extends StatelessWidget {
  final String imageUrl;

  const BlurBackground({Key key, @required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image(
          image: imageUrl != null ? CachedNetworkImageProvider(
            imageUrl.toString(),
          ) : new AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
          height: 15,
          width: 15,
          gaplessPlayback: true,
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaY: 14, sigmaX: 24),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54,
                Colors.black26,
                Colors.black45,
                Colors.black87,
              ],
            )),
          ),
        ),
      ],
    );
  }
}
