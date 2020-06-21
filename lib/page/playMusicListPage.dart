import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/components/songListItem.dart';
import 'package:music/database/playListDataBase.dart';

class PlayMusicListPage extends StatefulWidget {
  @override
  _PlayMusicListPageState createState() => _PlayMusicListPageState();
}

class _PlayMusicListPageState extends State<PlayMusicListPage> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF3E3E3E),
          baseColor: Colors.black,
          intensity: 0.5,
          lightSource: LightSource.topLeft,
          depth: 10,
        ),
        darkTheme: neumorphicDefaultDarkTheme.copyWith(
            defaultTextColor: Colors.white70),
        child: _Page());
  }
}

class _Page extends StatefulWidget {
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  TextEditingController controller;
  String _text;
  List<Widget> playList = [];
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.navigate_before,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )),
          Align(
            alignment: Alignment.center,
            child: Text(
              '我的歌单',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _addMusicMenu,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    Text(
                      '创建歌单',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();
    _getMusicMunu();
  }

  _addMusicMenu() async {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(builder: (context, setDialogState) {
        return Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text('新建歌单', style: TextStyle(fontSize: 16)),
                padding: EdgeInsets.only(left: 10.0),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                constraints: BoxConstraints(maxHeight: 50, minWidth: 200),
                child: Theme(
                  data: new ThemeData(primaryColor: Colors.black),
                  child: TextField(
                    controller: controller,
                    maxLength: 20, //最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
                    maxLines: 1, //最大行数
                    cursorColor: Colors.black,
                    cursorWidth: 1.0, //光标宽度
                    style: TextStyle(
                        fontSize: 14.0, color: Colors.black), //输入文本的样式
                    decoration: InputDecoration(
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.red))),
                    onChanged: (text) {
                      setDialogState(() {
                        _text = text;
                      });
                    },
                  ),
                ),
              ),
              Container(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                SizedBox(
                  width: 60,
                  child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('取消')),
                ),
                SizedBox(
                  width: 60,
                  child: FlatButton(
                      onPressed: _text != null && _text.length > 0
                          ? () {
                              _addMusicMunu();
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text('确定')),
                ),
              ]))
            ],
          ),
        );
      }),
    )..show();
  }

  _addMusicMunu() async {
    ByteData bytes = await rootBundle.load('assets/menu_cover.jpg');
    var buffer = bytes.buffer;
    var base64Image = base64.encode(Uint8List.view(buffer));
    await DataBasePlayListProvider.db
        .insetDB(menuName: this.controller.text, menuCover: base64Image);
    controller.text = '';
    _getMusicMunu();
  }

  _getMusicMunu() async {
    final List<PlayListDBInfoMation> _playList =
        await DataBasePlayListProvider.db.queryAll();
    var tempList = _playList
        .map((menu) => Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SimpleListTile(
                title: menu.menuName,
                leading: Container(
                    width: 60,
                    height: 60,
                    child: new Image.memory(base64Decode(menu.menuCover))),
                onTap: () {},
              ),
            ))
        .toList();

    setState(() {
      playList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
    return Scaffold(
      body: SafeArea(
        child: NeumorphicBackground(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),
              SizedBox(height: 10),
              Expanded(
                  child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  //设置四周圆角 角度
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                ),
                child: ListView(
                  children:
                      ListTile.divideTiles(tiles: playList, context: context)
                          .toList(),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}