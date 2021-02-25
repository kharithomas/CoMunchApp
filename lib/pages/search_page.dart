import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/shared_prefs.dart';
import './chat_page.dart';
import './profile_page.dart';
import '../services/database_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // data
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  List<DocumentSnapshot> searchResultList = [];
  bool isLoading = false;
  bool hasUserSearched = false;
  bool _isJoined = false;
  FirebaseUser _user;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DatabaseService databaseService;

  // initState()
  @override
  void initState() {
    super.initState();
    _getCurrentUserNameAndUid();
  }

  // functions
  _getCurrentUserNameAndUid() async {
    _user = await FirebaseAuth.instance.currentUser();
    databaseService = DatabaseService(uid: _user.uid);
  }

  _initiateSearch() async {
    searchResultList = []; // empty previous results
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseService
          .searchByGroupName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        //print("$searchResultSnapshot");
        snapshot.documents.forEach((doc) {
          searchResultList.add(doc);
        });
      });

      await databaseService
          .searchByUser(searchEditingController.text)
          .then((snapshot) {
        snapshot.documents.forEach((doc) {
          searchResultList.add(doc);
        });
        setState(() {
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      duration: Duration(milliseconds: 1500),
      content: Text(message,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0)),
    ));
  }

  _joinValueInGroup(
      String userName, String groupId, String groupName, String admin) async {
    bool value =
        await databaseService.isUserJoined(groupId, groupName, userName);
    setState(() {
      _isJoined = value;
    });
  }

  // creates unique chat id
  _getPrivateChatRoomId(String user, String user2) {
    List<String> words = [user, user2];
    words.sort();
    return "${words[0]}\_${words[1]}";
  }

  void _createPrivateChatRoom(String userName, String receiverUserName) {
    String chatRoomId = _getPrivateChatRoomId(userName, receiverUserName);
    List<String> users = [userName, receiverUserName];
    Map<String, dynamic> chatRoomMap = {
      "chatRoomId": chatRoomId,
      "users": users
    };
    databaseService.createChatRoom(chatRoomId, chatRoomMap);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatId: chatRoomId,
          chatName: receiverUserName,
          isGroup: false,
        ),
      ),
    );
  }

  // widgets
  Widget groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultList.length,
            itemBuilder: (context, index) {
              return resultTile(
                sharedPrefs.getName,
                searchResultList[index].data["groupId"] != null
                    ? searchResultList[index].data["groupId"]
                    : null,
                searchResultList[index].data["groupName"] != null
                    ? searchResultList[index].data["groupName"]
                    : searchResultList[index].data["fullName"],
                searchResultList[index].data["admin"] != null
                    ? searchResultList[index].data["admin"]
                    : null,
                searchResultList[index].data["email"] != null
                    ? searchResultList[index].data["email"]
                    : null,
              );
            })
        : Container();
  }

  Widget resultTile(String userName, String groupId, String chatName,
      String admin, String email) {
    if (groupId != null && admin != null) {
      _joinValueInGroup(
          userName, groupId, chatName, admin); // if chatroom is `group`
    }
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: CircleAvatar(
          radius: 30.0,
          backgroundColor:
              (groupId != null && admin != null) ? Colors.red : Colors.red,
          child: Text(chatName.substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.white))),
      title: Text(chatName, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        (groupId != null && admin != null) ? "Admin: $admin" : email,
      ),
      trailing: (groupId != null && admin != null)
          ? InkWell(
              onTap: () async {
                await databaseService.togglingGroupJoin(
                    groupId, chatName, userName);
                if (_isJoined) {
                  setState(() {
                    _isJoined = !_isJoined;
                  });
                  // await DatabaseService(uid: _user.uid).userJoinGroup(groupId, chatName, userName);
                  _showScaffold('Successfully joined the group "$chatName"');
                  Future.delayed(Duration(milliseconds: 2000), () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatId: groupId,
                          chatName: chatName,
                          isGroup: true,
                        ),
                      ),
                    );
                  });
                } else {
                  setState(() {
                    _isJoined = !_isJoined;
                  });
                  _showScaffold('Left the group "$chatName"');
                }
              },
              child: _isJoined
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black87,
                          border: Border.all(color: Colors.white, width: 1.0)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child:
                          Text('Joined', style: TextStyle(color: Colors.white)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child:
                          Text('Join', style: TextStyle(color: Colors.white)),
                    ),
            )
          // view profile button
          : InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      profileName: chatName,
                      email: email,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: (groupId != null && admin != null)
                      ? Colors.red
                      : Colors.red,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text('View', style: TextStyle(color: Colors.white)),
              ),
            ),
      // send message to user
      // : InkWell(
      //     onTap: () {
      //       //print(chatName);
      //       _createPrivateChatRoom(chatName);
      //     },
      //     child: Container(
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(10.0),
      //         color: (groupId != null && admin != null)
      //             ? Colors.red
      //             : Colors.red,
      //       ),
      //       padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      //       child: Text('Message', style: TextStyle(color: Colors.white)),
      //     ),
      //   ),
    );
  }

  // building the search page widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black87,
        title: Text('Search',
            style: TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: // isLoading ? Container(
          //   child: Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // )
          // :
          Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchEditingController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      autocorrect: false,
                      decoration: InputDecoration(
                          hintText: "Search for users, groups...",
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        _initiateSearch();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(40)),
                          child: Icon(Icons.search, color: Colors.white)))
                ],
              ),
            ),
            isLoading
                ? Container(child: Center(child: CircularProgressIndicator()))
                : groupList()
          ],
        ),
      ),
    );
  }
}
