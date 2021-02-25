import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/shared_prefs.dart';
import './search_page.dart';
import '../services/database_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_tile.dart';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  // data
  FirebaseUser _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _groups;

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser();
    _userName = sharedPrefs.getName;
    _email = sharedPrefs.getEmail;

    DatabaseService(uid: _user.uid).getUserGroups().then((snapshots) {
      //print(snapshots);
      setState(() {
        _groups = snapshots;
      });
    });
  }

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }

  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Create"),
      onPressed: () async {
        if (_groupName != null) {
          DatabaseService(uid: _user.uid)
              .createGroup(sharedPrefs.getName, _groupName);
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Create a group"),
      content: TextField(
          onChanged: (val) {
            _groupName = val;
          },
          style: TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // widgets
  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.group, color: Colors.grey[700], size: 75.0),
            SizedBox(height: 20.0),
            Text(
                "You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button below.",
                textAlign: TextAlign.center),
          ],
        ));
  }

  // build our groups list
  Widget groupsList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null &&
              snapshot.data['groups'].length != 0) {
            // print(snapshot.data['groups'].length);
            return ListView.builder(
              itemCount: snapshot.data['groups'].length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                int reqIndex = snapshot.data['groups'].length - index - 1;
                return ChatTile(
                  //userName: snapshot.data['fullName'],
                  chatId: _destructureId(snapshot.data['groups'][reqIndex]),
                  chatName: _destructureName(snapshot.data['groups'][reqIndex]),
                  isGroup: true,
                );
              },
            );
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Building the GroupPage widget
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
          'Groups',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23.0,
          ),
        ),
        //backgroundColor: Colors.black87,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              icon: Icon(Icons.search, color: Colors.white, size: 25.0),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchPage()));
              })
        ],
      ),
      drawer: AppDrawer(),
      body: groupsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.0),
        backgroundColor: Colors.grey[700],
        elevation: 0.0,
      ),
    );
  }
}
