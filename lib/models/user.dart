import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  final String uid;
  final String fullName;
  final String email;
  List<Map<String, String>> _favoritePlaces = [];

  User({
    this.uid,
    this.fullName,
    this.email,
  });

  // create user from firestore document snapshot
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc.documentID,
      fullName: doc['fullName'],
      email: doc['email'],
    );
  }

  List<Map<String, String>> get favoritePlaces {
    return [..._favoritePlaces];
  }

  int get favoritesListLength {
    return _favoritePlaces.length;
  }

  bool isFavoritePlace(String placeId) {
    return _favoritePlaces.any((place) => place['id'] == placeId);
  }

  void toggleFavorite(Map<String, String> favorite) {
    final index =
        _favoritePlaces.indexWhere((place) => place['id'] == favorite['id']);
    if (index >= 0) {
      _favoritePlaces.removeAt(index);
      print('Un-Favorited!');
    } else {
      _favoritePlaces.add({
        'id': favorite['id'],
        'name': favorite['name'],
        'imageRef': favorite['imageRef'],
        'rating': favorite['rating'],
      });
      print('Favorited!');
    }
    print('Favorites len: ${_favoritePlaces.length}');
    notifyListeners();
  }

  void removePlace(String placeId) {
    _favoritePlaces.removeWhere((place) => place['id'] == placeId);
    print('Item removed!');
    print('Favorites len: ${_favoritePlaces.length}');
    notifyListeners();
  }
}
