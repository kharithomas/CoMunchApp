/// TODO: Move places API key to a seperate file - for security

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import './places_details_page.dart';

const PLACES_API_KEY = 'AIzaSyACwvAsVU8fapm3Pvyffg_5uGuvTIKPRIY';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var _favoritePlaces = Provider.of<User>(context).favoritePlaces;

    String getImageUrl(String photoRef, int maxWidth) {
      const endpoint = 'https://maps.googleapis.com/maps/api/place/photo';
      return "$endpoint?maxwidth=$maxWidth&photoreference=$photoRef&key=$PLACES_API_KEY";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorite Places'),
      ),
      body: _favoritePlaces.length > 0
          ? ListView.builder(
              itemCount: _favoritePlaces.length,
              itemBuilder: (ctx, i) => Dismissible(
                key: ValueKey(_favoritePlaces.elementAt(i)['id']),
                onDismissed: (direction) {
                  Provider.of<User>(context, listen: false)
                      .removePlace(_favoritePlaces.elementAt(i)['id']);
                },
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) {
                  return showDialog(
                    context: (context),
                    builder: (ctx) => AlertDialog(
                      title: Text('Are you sure?'),
                      content: Text(
                          'Do you want to remove this place from your favorites list?'),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: Text('No'),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  margin: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 15,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacesDetailsPage(
                          placeId: _favoritePlaces.elementAt(i)['id'],
                          imageRef: _favoritePlaces.elementAt(i)['imageRef'],
                          // currently passes null lat, lng - reconfigure details to fix this issue
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 100.0,
                      height: 100.0,
                      child: Image.network(
                        getImageUrl(
                            _favoritePlaces.elementAt(i)['imageRef'], 100),
                        fit: BoxFit.cover,
                        height: 100.0,
                        width: 100.0,
                      ),
                    ),
                    title: Text(_favoritePlaces.elementAt(i)['name']),
                    subtitle: Text(_favoritePlaces.elementAt(i)['rating']),
                  ),
                ),
              ),
            )
          : Center(
              child: Text('You have no favorite places',
                  style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
            ),
    );
  }
}
