import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:off_the_map/current_story_controller.dart';
import 'package:off_the_map/partials/story.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

enum InfoWindowVisibility { VISIBLE, HIDDEN }

/// includes marker and infowindow
class InfoWindowMarker {
  static List<InfoWindowMarker> infoWindowMarkers = [];

  // all InfoWindowMarkers will be associated with a Story
  Story story;

  final LatLng infoWindowLatLng;

  /// widget that builds the infowindow
  final Widget infoWindow;

  // trying to center infowindow
  // TODO: find a better way to do this exactly and make sure it works on different screen sizes
  static const offsetFromMarker = Offset(0.01, 0.002);

  /// every InfoWindowMarker has custom tap behavior
  bool performMarkerAction = false;

  var infoWindowVisibilityController =
      StreamController<InfoWindowVisibility>.broadcast();

  InfoWindowMarker({this.infoWindow, this.story})
      : infoWindowLatLng = getOffsetLatLng(story.latLng);

  /// this will prevent memory leaks from the streamController `infoWindowVisibility`
  void dispose() {
    infoWindowVisibilityController.close();
  }

  /// returns latlng positioned above infowindow's parentLatLng
  static LatLng getOffsetLatLng(LatLng parentLatLng) {
    LatLng latLng = LatLng(0, 0);

    latLng.latitude = parentLatLng.latitude + offsetFromMarker.dx;
    latLng.longitude = parentLatLng.longitude + offsetFromMarker.dy;

    return latLng;
  }

  static void closeAllInfoWindows() {
    for (InfoWindowMarker infoWindowMarker
        in InfoWindowMarker.infoWindowMarkers) {
      infoWindowMarker.infoWindowVisibilityController
          .add(InfoWindowVisibility.HIDDEN);
    }
  }

  /// returns pair of markers that represents the infoWindowMarker
  List<Marker> getInfoWindowMarker() {
    return [
      Marker(
        point: infoWindowLatLng,
        builder: (context) {
          // when other marker is tapped, this will rebuild and make infowindow visible
          return StreamBuilder(
            initialData: InfoWindowVisibility.HIDDEN,
            stream: infoWindowVisibilityController.stream,
            builder: (context, snapshot) {
              bool visible =
                  snapshot.data == InfoWindowVisibility.VISIBLE ? true : false;
              return Visibility(visible: visible, child: infoWindow);
            },
          );
        },
        // TODO: figure out a way to make this fit the child content.
        // potentially after InfoWindow builds, it could pass size data back to parent
        width: 200,
        height: 165,
      ),
      Marker(
        point: story.latLng,
        builder: (ctx) => GestureDetector(
              onTap: () {
                InfoWindowMarker.closeAllInfoWindows();
                infoWindowVisibilityController
                    .add(InfoWindowVisibility.VISIBLE);
                var stories = Provider.of<List<Story>>(ctx);
                for (Story story in stories) {
                  if (story.title == this.story.title) {
                    Provider.of<CurrentStoryController>(ctx).currentStory = story;
                  }
                }
              },
              child: Container(
                child: Icon(
                  Icons.location_on,
                  size: 50.0,
                  color: kOrangeMarkerColor,
                ),
              ),
            ),
      ),
    ];
  }
}