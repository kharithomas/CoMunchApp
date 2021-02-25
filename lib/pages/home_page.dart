import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../shared/gradient_mask.dart';
import './search_page.dart';
import '../helper/shared_prefs.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_tile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  // data
  FirebaseUser _user;
  String _groupName;
  Stream _chatRoomsStream;

  @override
  void initState() {
    super.initState();
    _getUserAuthAndChatRooms();
  }

  // @override
  // void didChangeDependencies() {
  //   // check if user is verified
  //   if (_user.isEmailVerified != null && _user.isEmailVerified == false)
  //     Fluttertoast.showToast(
  //         msg: 'Please verify your email', toastLength: Toast.LENGTH_SHORT);
  // }

  // functions
  _getUserAuthAndChatRooms() async {
    _user = await FirebaseAuth.instance.currentUser();

    DatabaseService(uid: _user.uid)
        .getChatRooms(sharedPrefs.getName)
        .then((snapshots) {
      setState(() {
        _chatRoomsStream = snapshots;
      });
    });
  }

  String _destructureChatName(String str) {
    return str.replaceAll('_', '').replaceAll(sharedPrefs.getName, '');
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
  Widget noChatsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.chat, color: Colors.grey[700], size: 75.0),
          SizedBox(height: 20),
          Text(
            "You've not joined any chats, tap on the 'search' icon to find users",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // build our chats list
  Widget chatsList() {
    return StreamBuilder(
      stream: _chatRoomsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return ChatTile(
                  chatId: snapshot.data.documents[index].data['chatRoomId'],
                  chatName: _destructureChatName(
                      snapshot.data.documents[index].data['chatRoomId']),
                  isGroup: false,
                );
              },
            );
          } else {
            return noChatsWidget();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        //backgroundColor: Colors.transparent,
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
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23.0,
          ),
        ),
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
      body: chatsList(),
    );
  }

  @override
  // Enables persistent data across page views
  bool get wantKeepAlive => true;
}
