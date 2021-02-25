import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final String placeId;
  final String placeName;

  ResultsPage({this.placeId, this.placeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Center(
        child: Text(
          'You picked $placeName and $placeId',
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
