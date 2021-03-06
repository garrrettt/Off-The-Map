import 'package:flutter/material.dart';
import 'package:off_the_map/constants.dart';
import 'package:off_the_map/models/story.dart';

/// An individual story listed under a place page
class PlaceStory extends StatelessWidget {
  final Story story;
  final List<Widget> children;

  const PlaceStory({this.story, this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Garrett Smith —', style: kBoldText),
            Text(story.dateWritten.toString()),
          ],
        ),
        Text(story.text),
        Divider(),
        Material(
          color: kGrayBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children
          ),
        ),
      ],
    );
  }
}
