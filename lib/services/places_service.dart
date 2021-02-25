import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../models/place.dart';

class PlacesService {
  final _key = 'AIzaSyACwvAsVU8fapm3Pvyffg_5uGuvTIKPRIY';
  String _nextPageToken;
  String _previousPageToken;

  // Makes HTTP request and retrieves list of restaurant locations
  Future<List<Place>> getPlaces(double lat, double lng) async {
    // if page token set
    if (_nextPageToken != null && _previousPageToken != _nextPageToken) {
      var response = await http.get(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$_nextPageToken&key=$_key');
      var json = convert.jsonDecode(response.body);

      _previousPageToken = _nextPageToken; // old token
      if (json['next_page_token'] != null) {
        _nextPageToken = json['next_page_token']; // new token
        //print('token: ' + _nextPageToken);
      }

      var jsonResults = json['results'] as List;
      return jsonResults.map((place) => Place.fromJson(place)).toList();
    }
    // else page token not set
    else {
      var response = await http.get(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&rankby=distance&type=restaurant&key=$_key');
      var json = convert.jsonDecode(response.body);

      // Set our next page token if available
      if (json['next_page_token'] != null) {
        _nextPageToken = json['next_page_token'];
        //print('next token: ' + _nextPageToken);
      }

      var jsonResults = json['results'] as List;
      return jsonResults.map((place) => Place.fromJson(place)).toList();
    }
  }
}
