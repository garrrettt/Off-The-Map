import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:off_the_map/constants.dart';
import 'package:off_the_map/controllers/current_place_controller.dart';
import 'package:off_the_map/controllers/current_story_controller.dart';
import 'package:off_the_map/controllers/footer_controller.dart';
import 'package:off_the_map/models/place.dart';
import 'package:off_the_map/models/story.dart';
import 'package:off_the_map/objects/info_window_marker.dart';
import 'package:off_the_map/objects/info_window_template_widget.dart';
import 'package:off_the_map/views/partials/info_footer.dart';
import 'package:off_the_map/views/partials/map_area.dart';
import 'package:off_the_map/views/partials/place_story.dart';
import 'package:off_the_map/views/place_story_page.dart';
import 'package:provider/provider.dart';

/// the page for people to explore places and walking tours (walking tours not yet included)
class ExploreMapPage extends StatelessWidget {
  final MapAreaController mapAreaController = MapAreaController();
  final CurrentPlaceController currentPlaceController =
      CurrentPlaceController();
  final CurrentStoryController currentStoryController =
      CurrentStoryController();
  final FooterController footerController = FooterController();

  void onMarkerTap() {
    footerController.extended = true;
    print('true');

    footerController.replaceFooterContent(TopicList());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CurrentPlaceController>.value(value: currentPlaceController),
        Provider<List<Place>>.value(value: mapAreaController.places),
      ],
      child: ChangeNotifierProvider<CurrentStoryController>(
        builder: (context) => currentStoryController,
        child: ChangeNotifierProvider<FooterController>(
          builder: (context) => footerController,
          child: Scaffold(
            backgroundColor: kGrayBackgroundColor,
            appBar: AppBar(
              backgroundColor: kDarkBlueBackground,
              title: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration.collapsed(
                  hintText: 'Search Places',
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ),
            body: SafeArea(
              child: Consumer<FooterController>(
                builder: (context, footerController, child) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('places')
                              .snapshots(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                break;
                              default:
                                mapAreaController.places.clear();
                                snapshot.data.documents
                                    .forEach((DocumentSnapshot doc) {
                                  mapAreaController.places.add(
                                    Place.fromFirestore(doc),
                                  );
                                });
                            }

                            return MapArea(
                              infoWindowFactory:
                                  InfoWindowExplorePageTemplate(),
                              markerCustomTapCallback: onMarkerTap,
                            );
                          },
                        ),
                      ),
                      // footer
                      if (footerController.extended)
                        Expanded(
                          flex: 1,
                          child: InfoFooter(
                            child: TopicList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoWindowExplorePageTemplate implements InfoWindowTemplate {
  @override
  Widget generateInfoWindowTemplate({Place place}) {
    return InfoWindowExplorePage(place: place);
  }
}

class InfoWindowExplorePage extends StatelessWidget {
  final Place place;

  InfoWindowExplorePage({@required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.width * 0.3,
      padding: EdgeInsets.all(5.0),
      color: kOrangeMarkerColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  InfoWindowMarker.closeAllInfoWindows();
                  var footerController = Provider.of<FooterController>(context);
                  footerController.extended = false;
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Text(place.name)
        ],
      ),
    );
  }
}

class TopicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(CurrentPlaceController.currentPlace.name, style: kHeader),
        Text('Topics'),
        Flexible(
          child: StreamBuilder(
            stream: CurrentPlaceController.currentPlace.getStories(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  // populate currentPlaceController's `storiesByTopic`
                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                    final DocumentSnapshot document =
                        snapshot.data.documents[i];
                    Story story = Story.fromFirestore(document);

                    if (CurrentPlaceController.storiesByTopic
                        .containsKey(story.topic)) {
                      CurrentPlaceController.storiesByTopic[story.topic]
                          .add(story);
                    } else {
                      CurrentPlaceController.storiesByTopic
                          .putIfAbsent(story.topic, () => [story]);
                    }
                  }

                  // make listView of all topics coupled with the top story for that topic
                  return ListView.builder(
                    itemCount: CurrentPlaceController.storiesByTopic.length,
                    itemBuilder: (context, index) {
                      List<String> keys =
                          CurrentPlaceController.storiesByTopic.keys.toList();
                      String topic = keys[index];

                      Story topStory =
                          CurrentPlaceController.getTopStoryForTopic(topic);

                      return StoryTopicButton(
                        topic: topic,
                        stories: CurrentPlaceController.storiesByTopic[topic],
                      );
                    },
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}

class StoryTopicButton extends StatelessWidget {
  final List<Story> stories;
  final String topic;

  StoryTopicButton({this.stories, this.topic});

  @override
  Widget build(BuildContext context) {
    FooterController footerController = Provider.of<FooterController>(context);
    CurrentStoryController currentStoryController =
        Provider.of<CurrentStoryController>(context);

    Color purple = Color(0xFF93639A);

    return RaisedButton(
      color: purple,
      onPressed: () {
        // currentStoryController.currentStory = story;

        // change footer content to the story
        // footerController.replaceFooterContent(StoryFooterView());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return PlaceStoryPage(topic: topic, stories: CurrentPlaceController.storiesByTopic[topic]);
            },
          ),
        );
      },
      child: Text(
        topic,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class StoryFooterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CurrentStoryController currentStoryController =
        Provider.of<CurrentStoryController>(context);

    return Column(
      children: <Widget>[
        Text(CurrentPlaceController.currentPlace.name, style: kHeader),
        Text(currentStoryController.currentStory.topic),
        PlaceStory(
          story: currentStoryController.currentStory,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PlaceStoryPage(
                        topic: currentStoryController.currentStory.topic,
                        stories: CurrentPlaceController.storiesByTopic[
                            currentStoryController.currentStory.topic],
                      );
                    },
                  ),
                );
              },
              child: Text('See full story page', style: kAssignmentOptionStyle),
            ),
          ],
        ),
      ],
    );
  }
}
