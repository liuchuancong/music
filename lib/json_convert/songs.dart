class Songs {
  int result;
  SongsData data;

  Songs({this.result, this.data});

  Songs.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    data = json['data'] != null ? new SongsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class SongsData {
  List<SongList> list;
  int total;

  SongsData({this.list, this.total});

  SongsData.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = new List<SongList>();
      json['list'].forEach((v) {
        list.add(new SongList.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.list != null) {
      data['list'] = this.list.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class SongList {
  String name;
  String id;
  String cid;
  String mvId;
  String url;
  Album album;
  List<Artists> artists;

  SongList(
      {this.name,
      this.id,
      this.cid,
      this.mvId,
      this.url,
      this.album,
      this.artists});

  SongList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    cid = json['cid'];
    mvId = json['mvId'];
    url = json['url'];
    album = json['album'] != null ? new Album.fromJson(json['album']) : null;
    if (json['artists'] != null) {
      artists = new List<Artists>();
      json['artists'].forEach((v) {
        artists.add(new Artists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['cid'] = this.cid;
    data['mvId'] = this.mvId;
    data['url'] = this.url;
    if (this.album != null) {
      data['album'] = this.album.toJson();
    }
    if (this.artists != null) {
      data['artists'] = this.artists.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Album {
  String picUrl;
  String name;
  String id;

  Album({this.picUrl, this.name, this.id});

  Album.fromJson(Map<String, dynamic> json) {
    picUrl = json['picUrl'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['picUrl'] = this.picUrl;
    data['name'] = this.name;
    data['id'] = this.id;
    return data;
  }
}

class Artists {
  String id;
  String name;

  Artists({this.id, this.name});

  Artists.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
