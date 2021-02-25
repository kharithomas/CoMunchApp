import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/poll_tile.dart';
import '../widgets/app_drawer.dart';
import '../services/database_service.dart';

class PollsPage extends StatefulWidget {
  @override
  _PollsPageState createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  //Position _location = Position(latitude: 52.3676, longitude: 4.9041);
  //DatabaseService _databaseService;
  FirebaseUser _user;
  List<DocumentSnapshot> _userPolls = [];
  var _isLoading = false;

  initState() {
    _getUserAuthAndGroupPolls();
    super.initState();
  }

  // gets all user's polls
  _getUserAuthAndGroupPolls() async {
    setState(() {
      _isLoading = true;
    });
    _user = await FirebaseAuth.instance.currentUser();
    DatabaseService(uid: _user.uid).getGroupPolls().then((val) {
      // print(val);
      setState(() {
        _userPolls = val;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xffF5D020),
                  Color(0xffF53803),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          //iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Polls',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 23.0,
            ),
          ),
          //backgroundColor: Colors.black87,
          elevation: 0.0,
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _userPolls != null
                ? _userPolls.length > 0
                    ? ListView.builder(
                        itemCount: _userPolls.length,
                        itemBuilder: (context, index) {
                          return PollTile(
                            pollId: _userPolls[index].data['pollId'],
                            pollName: _userPolls[index].data['pollName'],
                            location: _userPolls[index].data['location'],
                          );
                        })
                    : Center(
                        child: Text(
                            'You currently have no polls to participate in.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24)),
                      )
                : Center(child: CircularProgressIndicator()));
  }
}
