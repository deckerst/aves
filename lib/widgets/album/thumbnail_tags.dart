import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';

class VideoTag extends StatelessWidget {
  final ImageEntry entry;
  final double iconSize;

  const VideoTag({Key key, this.entry, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tag(
      icon: Icons.play_circle_outline,
      iconSize: iconSize,
      text: entry.durationText,
    );
  }
}

class GifTag extends StatelessWidget {
  final double iconSize;

  const GifTag({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tag(
      icon: Icons.gif,
      iconSize: iconSize,
    );
  }
}

class GpsTag extends StatelessWidget {
  final double iconSize;

  const GpsTag({Key key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tag(
      icon: Icons.place,
      iconSize: iconSize,
    );
  }
}

class Tag extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String text;

  const Tag({Key key, this.icon, this.iconSize, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      padding: text != null ? EdgeInsets.only(right: iconSize / 4) : null,
      decoration: BoxDecoration(
        color: Color(0xBB000000),
        borderRadius: BorderRadius.all(
          Radius.circular(iconSize),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
          ),
          if (text != null) ...[
            SizedBox(width: 2),
            Text(text),
          ]
        ],
      ),
    );
  }
}
