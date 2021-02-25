import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../pages/discover_places_page.dart';
import '../helper/shared_prefs.dart';

class PollTile extends StatelessWidget {
  final String pollId;
  final String pollName;
  final String location;

  PollTile({this.pollId, this.pollName, this.location});

  Position _destructureLocation(String location) {
    final double lat =
        double.parse(location.substring(0, location.indexOf(",")));
    final double lng =
        double.parse(location.substring(location.indexOf(',') + 1));
    return Position(latitude: lat, longitude: lng);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DiscoverPlacesPage(
                    currentPosition: _destructureLocation(location),
                  )),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30.0,
            backgroundColor: Colors.red,
            child: Text(pollName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
          ),
          title: Text(pollName, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
