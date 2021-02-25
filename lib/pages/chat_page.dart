import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../services/database_service.dart';
import '../widgets/message_tile.dart';
import '../helper/shared_prefs.dart';

class ChatPage extends StatefulWidget {
  final String chatId; // can be groupId or chatRoomId
  final String chatName; // can be groupName or receiverName
  final bool isGroup;

  ChatPage({this.chatId, this.chatName, this.isGroup});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _pollName;
  String _pollLocation;
  Stream<QuerySnapshot> _chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget _chatMessages() {
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sender: snapshot.data.documents[index].data["sender"],
                    sentByMe: sharedPrefs.getName ==
                        snapshot.data.documents[index].data["sender"],
                  );
                })
            : Container();
      },
    );
  }

  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": sharedPrefs.getName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService()
          .sendMessage(widget.chatId, chatMessageMap, widget.isGroup);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  // create a group poll
  _createPoll({String groupId, String pollName, String location}) {
    Map<String, dynamic> groupPollMap = {
      'pollId': '',
      'pollName': pollName,
      'location': location,
      'participants': [],
      'time': DateTime.now().millisecondsSinceEpoch,
      'isExpired': false,
    };
    DatabaseService().createGroupPoll(groupId, groupPollMap);

    Fluttertoast.showToast(msg: 'Poll Successfully Created!');
  }

  @override
  void initState() {
    super.initState();

    // retreive past group messages
    if (widget.isGroup) {
      DatabaseService().getGroupMessages(widget.chatId).then((val) {
        // print(val);
        setState(() {
          _chats = val;
        });
      });
    } else {
      DatabaseService().getPrivateMessages(widget.chatId).then((val) {
        // print(val);
        setState(() {
          _chats = val;
        });
      });
    }
  }

  // widgets
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
        if (_pollName != null && _pollLocation != null) {
          // create new poll
          _createPoll(
            groupId: widget.chatId,
            pollName: _pollName,
            location: _pollLocation,
          );
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Name Group Poll"),
      content: Column(
        children: [
          TextField(
            onChanged: (val) {
              _pollName = val;
            },
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: '(e.g. Favorite Foods)',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black),
          ),
          TextField(
            onChanged: (val) {
              _pollLocation = val;
            },
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: '(e.g. 32.7291,-97.1121)',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black),
          ),
        ],
      ),
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

  Widget _popupMenu() {
    return PopupMenuButton(
      onSelected: (value) {
        switch (value) {
          case 0:
            _popupDialog(context);
            break;
          case 1:
            print('Add new member');
            break;
          case 2:
            print('Open group settings');
            break;
          default:
            print('Invalid option selected. Please try again.');
        }
        // Fluttertoast.showToast(
        //     msg: "You have selected " + value.toString(),
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.black,
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.how_to_vote_rounded, color: Colors.black),
              ),
              Text('Create Poll')
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.person_add, color: Colors.black),
              ),
              Text('Add Member')
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(Icons.settings, color: Colors.black),
              ),
              Text('Settings')
            ],
          ),
        ),
      ],
    );
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
        title: Text(widget.chatName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0.0,
        actions: [
          widget.isGroup ? _popupMenu() : Container(),
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 50),
              child: _chatMessages(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[700],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageEditingController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Send a message ...",
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () {
                        _sendMessage();
                      },
                      child: Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: Icon(Icons.send, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
