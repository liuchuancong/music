class DownLoadFileInfo {
  int result;
  Data data;

  DownLoadFileInfo({this.result, this.data});

  DownLoadFileInfo.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  String name;
  String id;
  String cid;
  List<Artists> artists;
  Album album;
  String desc;
  String url;

  Data(
      {this.name,
      this.id,
      this.cid,
      this.artists,
      this.album,
      this.desc,
      this.url});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    cid = json['cid'];
    if (json['artists'] != null) {
      artists = new List<Artists>();
      json['artists'].forEach((v) {
        artists.add(new Artists.fromJson(v));
      });
    }
    album = json['album'] != null ? new Album.fromJson(json['album']) : null;
    desc = json['desc'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['cid'] = this.cid;
    if (this.artists != null) {
      data['artists'] = this.artists.map((v) => v.toJson()).toList();
    }
    if (this.album != null) {
      data['album'] = this.album.toJson();
    }
    data['desc'] = this.desc;
    data['url'] = this.url;
    return data;
  }
}

class Artists {
  String id;
  String name;
  String nameSpelling;

  Artists({this.id, this.name, this.nameSpelling});

  Artists.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameSpelling = json['nameSpelling'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['nameSpelling'] = this.nameSpelling;
    return data;
  }
}

class Album {
  String name;
  String id;
  String picUrl;

  Album({this.name, this.id, this.picUrl});

  Album.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    picUrl = json['picUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['picUrl'] = this.picUrl;
    return data;
  }
}
