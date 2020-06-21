import 'package:flutter/material.dart';
import 'package:music/json_convert/songs.dart';

class CurrentSong with ChangeNotifier {
  //1
  SongList _song = new SongList();
  List<SongList> _playList = [];
  List<SongList> _tempPlayList = [];
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
   void settempPlayList(List<SongList> playList) {
    this._tempPlayList = playList;
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
  void insertTempPlatList(int index, SongList song) {
    this._tempPlayList.insert(index, song);
    notifyListeners();
  }

  void removeAtIndex(int index) {
    this._tempPlayList.removeAt(index);
    
    notifyListeners();
  }
  SongList get song => _song;
  List<SongList> get playList => _playList;
  List<SongList> get tempPlayList => _tempPlayList;
  bool get playState => _play;
}
