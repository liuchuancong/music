import 'dart:convert';
import 'package:backdrop/backdrop.dart';
import 'package:backdrop/scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/components/audioControl.dart';
import 'package:music/plugin/audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'common/textColor.dart';
import 'components/songListItem.dart';
import 'components/textField.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'json_convert/songs.dart';
import 'package:provider/provider.dart';
import 'model/currentSong.dart';

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => CurrentSong(null)),
    ], child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Music',
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
  //  Current State of InnerDrawerState
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();
  Dio dio = new Dio();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int pageNo = 1;
  String _text = '';
  List<Widget> songsList = [];
  SongList currentPlay;
  List<SongList> playList = [];
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
        getSongsDetail(songs.data);
      } else {
        _refreshController.loadFailed();
      }
    } catch (e) {
      _refreshController.loadFailed();
    }
  }

  void _payMusic(SongList song) {
    context.read<CurrentSong>().setSong(song);
    AudioInstance().initAudio(song);
  }

  void _onLoading() async {
    this.getSongList();
  }

  getSongsDetail(SongsData songsData) {
    if (songsData != null &&
        songsData.list != null &&
        songsData.list.length > 0) {
      playList.addAll(songsData.list);
      context.read<CurrentSong>().setPlayList(playList);
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
      setState(() {
        songsList.addAll(songs);
        pageNo++;
      });
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  _playAllMusic() {
    if (playList.length == 0) {
      return;
    }
    AudioInstance().initAudioList(playList).then((value) => {
          context.read<CurrentSong>().setTempplayList(playList),
          context.read<CurrentSong>().setSong(playList[
              AudioInstance().assetsAudioPlayer.readingPlaylist.currentIndex])
        });
  }

  Widget build(BuildContext context) {
    return InnerDrawer(
      key: _innerDrawerKey,
      leftChild: Material(
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFDDE6E8)),
          child: ListView(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ListTile(
                title: Text('我喜欢的'),
              )
            ],
          ),
        ),
      ),
      scale: IDOffset.horizontal(0.8),
      proportionalChildArea: true,
      backgroundDecoration: BoxDecoration(color: Color(0xFFDDE6E8)),
      onTapClose: true,
      borderRadius: 50,
      leftAnimationType: InnerDrawerAnimation.quadratic, // default static
      scaffold: BackdropScaffold(
          backLayerBackgroundColor: Color(0xFF000000),
          appBar: BackdropAppBar(
            backgroundColor: Color(0xFF000000),
            actionsIconTheme: NeumorphicTheme.currentTheme(context).iconTheme,
            leading: IconButton(
              icon: new NeumorphicIcon(Icons.menu),
              onPressed: () {
                _innerDrawerKey.currentState
                    .toggle(direction: InnerDrawerDirection.start);
              },
            ),
            title: NeumorphicText(
              "Flutter Music",
              style: NeumorphicStyle(
                depth: 4, //customize depth here
                color: Colors.white, //customize color here
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 18, //customize size here
              ),
            ),
            actions: <Widget>[
              BackdropToggleButton(
                icon: AnimatedIcons.view_list,
              )
            ],
          ),
          subHeader: BackdropSubHeader(
              title: Row(
            children: <Widget>[
              NeumorphicButton(
                style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    depth: 1,
                    intensity: 1,
                    boxShape: NeumorphicBoxShape.stadium()),
                onPressed: _playAllMusic,
                child: NeumorphicText(
                  '全部播放',
                  style: NeumorphicStyle(
                    depth: 0, //customize depth here
                    color: textColor(context), //customize color here
                  ),
                  textStyle: NeumorphicTextStyle(fontSize: 10),
                ),
              )
            ],
          )),
          backLayer: context.watch<CurrentSong>().tempplayList.length > 0
              ? BackdropNavigationBackLayer(
                  onTap: (int index) {
                    context.read<CurrentSong>().setSong(
                        context.read<CurrentSong>().tempplayList[index]);
                    AudioInstance().playlistPlayAtIndex(index);
                  },
                  items: context
                      .watch<CurrentSong>()
                      .tempplayList
                      .map((song) => SongListItem(
                            song: song,
                          ))
                      .toList(),
                )
              : null,
          frontLayer: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              TextSearchField(
                hint: "请输入歌曲名或者作者",
                onSubmit: (text) {
                  setState(() {
                    _text = text;
                    pageNo = 1;
                    songsList = [];
                    playList = [];
                  });
                  getSongList();
                },
              ),
              Expanded(
                child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = NeumorphicText(
                          "上拉加载更多~",
                          style: NeumorphicStyle(
                            depth: 4, //customize depth here
                            color: textColor(context), //customize color here
                          ),
                          textStyle: NeumorphicTextStyle(),
                        );
                      } else if (mode == LoadStatus.loading) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = NeumorphicText(
                          "加载失败,请稍后重试~",
                          style: NeumorphicStyle(
                            depth: 4, //customize depth here
                            color: textColor(context), //customize color here
                          ),
                          textStyle: NeumorphicTextStyle(),
                        );
                      } else if (mode == LoadStatus.canLoading) {
                        body = NeumorphicText(
                          "松开加载~",
                          style: NeumorphicStyle(
                            depth: 4, //customize depth here
                            color: textColor(context), //customize color here
                          ),
                          textStyle: NeumorphicTextStyle(),
                        );
                      } else {
                        body = NeumorphicText(
                          "没有更多了",
                          style: NeumorphicStyle(
                            depth: 4, //customize depth here
                            color: textColor(context), //customize color here
                          ),
                          textStyle: NeumorphicTextStyle(),
                        );
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshController,
                  onLoading: _onLoading,
                  header: WaterDropHeader(),
                  child: ListView(
                    children:
                        ListTile.divideTiles(tiles: songsList, context: context)
                            .toList(),
                  ),
                ),
              ),
              context.watch<CurrentSong>().song != null
                  ? MyPageWithAudio(
                      currentPlay: context.watch<CurrentSong>().song)
                  : Container()
            ],
          )),
    );
  }
}
