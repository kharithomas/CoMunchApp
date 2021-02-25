import 'package:flutter/foundation.dart';

import 'geometry.dart';

class Place {
  final String placeId;
  final String name;
  final String imageRef;
  final double rating;
  final int userRatingCount;
  final String vicinity;
  final Geometry geometry;
  List<String> reviews;
  bool isOpen;

  Place({
    @required this.placeId,
    @required this.name,
    @required this.rating,
    @required this.imageRef,
    @required this.userRatingCount,
    @required this.vicinity,
    @required this.geometry,
    @required this.reviews,
    @required this.isOpen,
  });

  Place.fromJson(Map<dynamic, dynamic> parsedJson)
      : placeId = parsedJson['place_id'],
        name = parsedJson['name'],
        rating = (parsedJson['rating'] != null)
            ? parsedJson['rating'].toDouble()
            : null,
        imageRef = parsedJson['photos'] != null
            ? parsedJson['photos'][0]['photo_reference'] != null
                ? parsedJson['photos'][0]['photo_reference']
                : null
            : null,
        userRatingCount = (parsedJson['user_ratings_total'] != null)
            ? parsedJson['user_ratings_total']
            : null,
        vicinity = parsedJson['vicinity'],
        geometry = Geometry.fromJson(parsedJson['geometry']),
        reviews = (parsedJson['reviews'] != null)
            ? List.from(parsedJson['reviews'])
            : null,
        isOpen = parsedJson['opening_hours'] != null
            ? parsedJson['opening_hours']['open_now']
            : false;
}
