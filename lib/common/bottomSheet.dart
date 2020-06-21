import 'package:flutter/material.dart';
import 'package:music/json_convert/songs.dart';

class BottomSheetManage {
  Future showBottomSheet(
      SongList song, BuildContext context, List<Widget> optionList) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        builder: (BuildContext bc) {
          return SafeArea(
            child: new Column(
                mainAxisSize: MainAxisSize.min, children: optionList),
          );
        });
  }



  Future showDownLoadBottomSheet(BuildContext context, List<Widget> optionList) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        builder: (BuildContext bc) {
          return SafeArea(
            child: new Column(
                mainAxisSize: MainAxisSize.min, children: optionList),
          );
        });
  }
}
