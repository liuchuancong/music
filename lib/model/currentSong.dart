import 'package:flutter/material.dart';
import 'package:music/json_convert/songs.dart';

class CurrentSong with ChangeNotifier {
  //1
  SongList _song = new SongList();
  List<SongList> _playList = [];
  CurrentSong(this._song);
  bool _play = false;
  void setSong(SongList song) {
    this._song = song;
    notifyListeners();
  }

  void setPlayList(List<SongList> playList) {
    this._playList = playList;
    notifyListeners();
  }

  void setCurrentSong(int index) {
    this._song = this._playList[index];
    notifyListeners();
  }

  void setPlayState(bool play) {
    this._play = play;
    notifyListeners();
  }

  SongList get song => _song;
  List<SongList> get playList => _playList;
  bool get playState => _play;
}
