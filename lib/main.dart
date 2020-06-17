import 'dart:convert';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/theme/ThemeConfigurator.dart';
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

  int pageNo = 2;

  String _text = '';
  SongsData songsData = new SongsData();
  List<Widget> songsList = [];
  void getSongList() async {
    try {
      Response response = await Dio().get("http://api.migu.jsososo.com/search",
          queryParameters: {'keyword': _text, 'pageNo': pageNo});
      print(response.data);
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

  getSongsDetail() {
    if (songsData != null && songsData.list != null) {
      var songs = songsData.list.map((e) => ListTile(
            leading: e.album.picUrl != null ? new Image.network(e.album.picUrl): new Text(e.name),
            title: new Text(e.name),
          ));
      setState(() {
        songsList = songs.toList();
      });
    }
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
        body: ListView(
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
            Column(children: songsList)
          ],
        ));
  }
}
