import 'package:flutter/material.dart';
import 'package:off_the_map/constants.dart';
import 'package:off_the_map/controllers/footer_controller.dart';
import 'package:provider/provider.dart';

/// A simple footer that takes a child widget
class InfoFooter extends StatelessWidget {
  final Widget child;

  InfoFooter({this.child});

  @override
  Widget build(BuildContext context) {
    FooterController footerController = Provider.of<FooterController>(context);

    return Container(
      color: kGrayBackgroundColor,
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Flexible(
            child: child
          ),
          FlatButton(
            onPressed: () {
              footerController.extended = false;
            },
            child: Text('Close', style: kAssignmentOptionStyle),
          ),
        ],
      ),
    );
  }
}
