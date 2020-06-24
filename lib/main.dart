import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:backdrop/backdrop.dart';
import 'package:backdrop/scaffold.dart';
import 'package:music/page/downloadPage.dart';
import 'package:music/page/local_music_page.dart';
import 'package:music/page/playMusicListPage.dart';
import 'package:music/plugin/download.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/components/audioControl.dart';
import 'package:music/plugin/audio.dart';
import 'package:music/settings/dio_setting.dart';
import 'package:permission_handler/permission_handler.dart';
import 'common/textColor.dart';
import 'components/main_list_item.dart';
import 'components/niceButtonGrop.dart';
import 'components/songListItem.dart';
import 'components/textField.dart';
import 'package:dio/dio.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'json_convert/songs.dart';
import 'package:provider/provider.dart';
import 'main_method.dart';
import 'model/currentDownLoad.dart';
import 'model/currentSong.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.black);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CurrentSong(null)),
    ChangeNotifierProvider(create: (_) => CurrentDownLoad()),
  ], child: MyApp()));
}

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
  ReceivePort _port = ReceivePort();
  @override
  void initState() {
    requestPermission();
    DownLoadInstance().prepare();
    _portListen();
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    AudioInstance().dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return InnerDrawer(
        key: _innerDrawerKey,
        leftChild: Scaffold(
          body: Container(
            decoration: BoxDecoration(color: Color(0xFFDDE6E8)),
            child: ListView(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                NiceButtonGroup(
                  onTap: () {
                    _openRoute(page: DownLoadPage());
                  },
                  icon: Icons.file_download,
                  title: '下载管理',
                ),
                NiceButtonGroup(
                  onTap: () {
                    _openRoute(page: PlayMusicListPage());
                  },
                  icon: Icons.library_music,
                  title: '我的歌单',
                ),
                NiceButtonGroup(
                  onTap: () {
                    _openRoute(page: LocalMusicPage());
                  },
                  icon: Icons.music_note,
                  title: '本地音乐',
                ),
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
        scaffold: _buildBackDrop());
  }

  List<Widget> _buildTempPlayList(BuildContext ctx) {
    return ctx
        .watch<CurrentSong>()
        .tempPlayList
        .map((song) => SongListItem(
              song: song,
              onPressed: () {
                MainMethod().showBottomSheet(song: song, context: context);
              },
            ))
        .toList();
  }

  Widget _buildBackDrop() {
    return BackdropScaffold(
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
        backLayer: context.watch<CurrentSong>().tempPlayList.length > 0
            ? BackdropNavigationBackLayer(
                onTap: (int index) {
                  AudioInstance().playlistPlayAtIndex(index).then((value) => {
                        context.read<CurrentSong>().setSong(
                              context.read<CurrentSong>().tempPlayList[index],
                            )
                      });
                },
                items: _buildTempPlayList(context))
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
                ? MyPageWithAudio()
                : Container()
          ],
        ));
  }

  _portListen() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    FlutterDownloader.registerCallback(downloadCallback);
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      context.read<CurrentDownLoad>().setDownLoadAbleItem(
          new DownLoadAbleItem(id: id, progress: progress, status: status));
    });
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
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
      Response response = await Dio(dioOptions).get(
          "http://api.migu.jsososo.com/search",
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
    context.read<CurrentSong>().settempPlayList([song]);
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
          .map((song) => MainListItem(
                context: context,
                onTap: () {
                  _payMusic(song);
                },
                song: song,
                icon: Icons.more_vert,
                trailingTap: () {
                  MainMethod().showBottomSheet(song: song, context: context);
                },
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
          context.read<CurrentSong>().settempPlayList(playList),
          context.read<CurrentSong>().setSong(playList[
              AudioInstance().assetsAudioPlayer.readingPlaylist.currentIndex])
        });
  }

  _openRoute({@required Widget page}) {
    //打开B路由
    Navigator.push(context, PageRouteBuilder(pageBuilder: (BuildContext context,
        Animation animation, Animation secondaryAnimation) {
      return new FadeTransition(
        opacity: animation,
        child: page,
      );
    })).then((value) => {_innerDrawerKey.currentState.close()});
  }
}
