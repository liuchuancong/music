import 'dart:convert';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/components/audioControl.dart';
import 'package:music/plugin/audio.dart';
import 'package:music/theme/ThemeConfigurator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'common/textColor.dart';
import 'components/textField.dart';
import 'package:dio/dio.dart';

import 'json_convert/songs.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFFFFFFF),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dio dio = new Dio();

  int pageNo = 1;

  String _text = '';
  SongsData songsData = new SongsData();
  List<Widget> songsList = [];
  SongList currentPlay;
  bool _play = false;
  @override
  void initState() {
    requestPermission();
    super.initState();
  }

  // 申请权限
  Future<void> requestPermission() async {
    var status = await Permission.storage.status;

    if (status.isUndetermined) {
      await Permission.storage.request();
    }
  }

  void getSongList() async {
    try {
      Response response = await Dio().get("http://api.migu.jsososo.com/search",
          queryParameters: {'keyword': _text, 'pageNo': pageNo});
      Map songsMap = json.decode(response.toString());
      Songs songs = new Songs.fromJson(songsMap);
      if (songs.result == 100) {
        setState(() {
          songsData = songs.data;
        });
        getSongsDetail();
      }
    } catch (e) {
      print(e);
    }
  }

  void _payMusic(SongList song) {
    setState(() {
      currentPlay = song;
    });
    AudioInstance().initAudio(song.url);
  }

  getSongsDetail() {
    if (songsData != null && songsData.list != null) {
      var usefulList = songsData.list.where((item) => item.url != null);
      var songs = usefulList
          .map((e) => Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: e.album.picUrl != null
                      ? new Image.network(e.album.picUrl)
                      : new Image.asset('assets/notFound.jpeg'),
                  title: new Text(e.name),
                  subtitle: new Text(e.artists[0].name),
                  onTap: () {
                    _payMusic(e);
                  },
                ),
              ))
          .toList();
      print(songs);
      setState(() {
        songsList = songs;
      });
    }
  }

  playOrPause() async {
    setState(() {
      _play = !_play;
    });
    await AudioInstance().assetsAudioPlayer.playOrPause();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NeumorphicAppBar(
          title: NeumorphicText(
            "I love flutter",
            style: NeumorphicStyle(
              depth: 4, //customize depth here
              color: textColor(context), //customize color here
            ),
            textStyle: NeumorphicTextStyle(
              fontSize: 18, //customize size here
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: 20,
              child: ThemeConfigurator(),
            )
          ],
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: Column(
          children: <Widget>[
            TextSearchField(
              hint: "请输入歌曲名或者作者",
              onSubmit: (text) {
                setState(() {
                  _text = text;
                });
                getSongList();
              },
            ),
            Expanded(
              child: ListView(
                children:
                    ListTile.divideTiles(tiles: songsList, context: context)
                        .toList(),
              ),
            ),
            currentPlay != null
                ? MyPageWithAudio(currentPlay: currentPlay)
                : Container()
          ],
        ));
  }
}
