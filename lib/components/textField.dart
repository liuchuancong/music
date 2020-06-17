import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music/common/textColor.dart';

class TextSearchField extends StatefulWidget {
  final String hint;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  TextSearchField({@required this.hint, this.onChanged,this.onSubmit});

  @override
  _TextSearchFieldState createState() => _TextSearchFieldState();
}

class _TextSearchFieldState extends State<TextSearchField> {
  TextEditingController _controller;
  double _height = 60.0;
  @override
  void initState() {
    _controller = TextEditingController(text: widget.hint);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width - 50,
          height: _height,
          child: Neumorphic(
            margin: EdgeInsets.only(left: 18, right: 18, top: 2, bottom: 4),
            style: NeumorphicStyle(
              depth: NeumorphicTheme.embossDepth(context),
              boxShape: NeumorphicBoxShape.stadium(),
            ),
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 18),
            child: TextField(
              onChanged: this.widget.onChanged,
              onSubmitted: this.widget.onSubmit,
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: this.widget.hint),
            ),
          ),
        ),
        Container(
            width: 50,
            padding: EdgeInsets.only(right: 10),
            height: _height,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.clear();
                  });
                },
                child: NeumorphicIcon(
                  Icons.clear,
                  size: 25,
                  style: NeumorphicStyle(
                    depth: 1, //customize depth here
                    color: textColor(context), //customize color here
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
