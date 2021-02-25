/// Created by: Glenda Robertson on 10/05/2020
/// Edited by: Khari Thomas on 10/27/2020
///
/// TODO: Create unlimited card list

import 'dart:async';

import '../services/geolocator_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swipe_stack/swipe_stack.dart';

import '../models/place.dart';
import '../widgets/discover_card_item.dart';
import './favorites_page.dart';
import '../services/places_service.dart';
import './results_page.dart';

class DiscoverPlacesPage extends StatefulWidget {
  static const routeName = '/discover';
  Position currentPosition;
  final bool isPoll;

  DiscoverPlacesPage({Key key, this.currentPosition, this.isPoll = false})
      : super(key: key);

  @override
  _DiscoverPlacesPageState createState() => _DiscoverPlacesPageState();
}

class _DiscoverPlacesPageState extends State<DiscoverPlacesPage>
    with AutomaticKeepAliveClientMixin {
  PlacesService _placesService;
  List<Place> _places;
  var _isEnd = false;

  // functions
  @override
  void initState() {
    _getLocalPlaces();
    super.initState();
  }

  // get places near current position
  _getLocalPlaces() async {
    if (widget.currentPosition == null) {
      widget.currentPosition = await GeoLocatorService().getLocation();
    }
    _placesService = PlacesService();
    _placesService
        .getPlaces(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    )
        .then((value) {
      setState(() {
        _places = value;
      });
    });
  }

  // send to results page
  _sendToResults(String placeId, String placeName) {
    // delay 0.5 second then navigate
    Timer(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            placeId: placeId,
            placeName: placeName,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: _places != null && widget.currentPosition != null
              ? _isEnd != true
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.70,
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: SwipeStack(
                            children: _places.map((Place place) {
                              return SwiperItem(builder:
                                  (SwiperPosition position, double progress) {
                                return DiscoverCardItem(
                                  id: place.placeId,
                                  name: place.name,
                                  imageRef: place.imageRef,
                                  rating: place.rating,
                                  isOpen: place.isOpen,
                                  lat: place.geometry.location.lat,
                                  lng: place.geometry.location.lng,
                                );
                              });
                            }).toList(),
                            visibleCount: 3,
                            stackFrom: StackFrom.Top,
                            translationInterval: 6,
                            scaleInterval: 0.03,
                            onEnd: () {
                              setState(() {
                                _isEnd = true;
                              });
                            },
                            onSwipe: (int index, SwiperPosition position) {
                              // right swipe
                              if (widget.isPoll) {
                                if (position == SwiperPosition.Right &&
                                    widget.isPoll) {
                                  _sendToResults(
                                    _places[index].placeId,
                                    _places[index].name,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        RaisedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => FavoritesPage()));
                          },
                          child: Text(
                            'To Favs Screen',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.red,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant,
                            color: Colors.grey[700], size: 75.0),
                        SizedBox(height: 20.0),
                        Text("There are no more places available.",
                            textAlign: TextAlign.center),
                        FlatButton(
                          color: Colors.red,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Continue',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  // Enables persistent data across page views
  bool get wantKeepAlive => true;
}
