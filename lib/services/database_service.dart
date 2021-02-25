import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

User currentUser; // TODO: use provider here instead

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference groupCollection =
      Firestore.instance.collection('groups');
  final CollectionReference chatRoomCollection =
      Firestore.instance.collection('chatrooms');

  Future<void> setUserData(
      String fullName, String email, String password) async {
    await userCollection.document(uid).setData({
      'fullName': fullName,
      'email': email,
      'password': password,
      'groups': [],
      'profilePic': ''
    });

    // create new User model from Firestore user
    DocumentSnapshot doc = await userCollection.document(uid).get();
    currentUser = User.fromDocument(doc);
    //print(currentUser);
    //print(currentUser.fullName);
  }

  // update userdata
  Future<void> updateUserData({String fullName, String email}) async {
    await Firestore.instance.collection('users').document(uid).updateData({
      'fullName': fullName,
      'email': email,
    });
  }

  // create group
  Future createGroup(String userName, String groupName) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await groupDocRef.updateData({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      'groupId': groupDocRef.documentID
    });

    DocumentReference userDocRef = userCollection.document(uid);
    return await userDocRef.updateData({
      'groups':
          FieldValue.arrayUnion([groupDocRef.documentID + '_' + groupName])
    });
  }

  // toggling the user group join
  Future togglingGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.document(groupId);

    List<dynamic> groups = await userDocSnapshot.data['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('hey');
      await userDocRef.updateData({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });

      await groupDocRef.updateData({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
      });
    } else {
      //print('nay');
      await userDocRef.updateData({
        'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      });

      await groupDocRef.updateData({
        'members': FieldValue.arrayUnion([uid + '_' + userName])
      });
    }
  }

  // has user joined the group
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> groups = await userDocSnapshot.data['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('he');
      return true;
    } else {
      //print('ne');
      return false;
    }
  }

  // get user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).getDocuments();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    //return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return userCollection.document(uid).snapshots();
  }

  // get recommended users
  getRecommendedUsers() async {
    return await userCollection.getDocuments();
  }

  // get single chat rooms
  getChatRooms(String userName) async {
    return chatRoomCollection
        .where("users", arrayContains: userName)
        .snapshots();
  }

  // send message
  sendMessage(String chatId, chatMessageData, bool isGroup) {
    if (isGroup) {
      Firestore.instance
          .collection('groups')
          .document(chatId)
          .collection('messages')
          .add(chatMessageData)
          .catchError((error) {
        throw error;
      });
      groupCollection.document(chatId).updateData({
        'recentMessage': chatMessageData['message'],
        'recentMessageSender': chatMessageData['sender'],
        'recentMessageTime': chatMessageData['time'].toString(),
      }).catchError((error) {
        throw error;
      });
    } else {
      Firestore.instance
          .collection('chatrooms')
          .document(chatId)
          .collection('messages')
          .add(chatMessageData)
          .catchError((error) {
        throw error;
      });
    }
  }

  // get all messages of a group
  getGroupMessages(String groupId) async {
    return Firestore.instance
        .collection('groups')
        .document(groupId)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots();
  }

  // get all messages of a private chat
  getPrivateMessages(String chatRoomId) async {
    return Firestore.instance
        .collection('chatrooms')
        .document(chatRoomId)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots();
  }

  // get polls of a user group
  Future<List<DocumentSnapshot>> getGroupPolls() async {
    List<DocumentSnapshot> polls = [];
    List<String> groupIdList = [];
    var docSnapshot = await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .catchError((error) {
      throw error;
    });
    var userGroups = docSnapshot.data['groups'];
    // get user groups
    for (int i = 0; i < userGroups.length; i++) {
      String groupId =
          userGroups[i].toString().substring(0, userGroups[i].indexOf('_'));
      groupIdList.add(groupId);
    }

    // get all polls
    for (int i = 0; i < groupIdList.length; i++) {
      // TODO: extract to method
      var docSnapshot2 = await Firestore.instance
          .collection('groups')
          .document(groupIdList[i])
          .collection('polls')
          .getDocuments()
          .catchError((error) {
        throw error;
      });
      polls = polls + docSnapshot2.documents; // add to list
    }

    polls.forEach((poll) {
      print(poll.data['pollName']);
    });

    return polls;
  }

  // search groups
  searchByGroupName(String groupName) {
    return Firestore.instance
        .collection("groups")
        .where('groupName', isEqualTo: groupName)
        .getDocuments();
  }

  // search users
  searchByUser(String fullName) async {
    return await Firestore.instance
        .collection('users')
        .where('fullName', isEqualTo: fullName)
        //.where('fullName', "!=", currentUserName)
        .getDocuments();
  }

  // create chatroom
  createChatRoom(String roomId, roomMap) {
    Firestore.instance
        .collection('chatrooms')
        .document(roomId)
        .setData(roomMap)
        .catchError((error) {
      throw error;
    });
  }

  // create group poll
  createGroupPoll(String groupId, pollMap) async {
    DocumentReference pollDocRef = await Firestore.instance
        .collection('groups')
        .document(groupId)
        .collection('polls')
        .add(pollMap)
        .catchError((error) {
      throw error;
    });
    await pollDocRef.updateData({
      'pollId': pollDocRef.documentID,
    });
  }
}

// .collection("polls")
// .where("participants", "array-contains", "eHv1YfCRmLRioWMiDiCBdTTM3Uh1_joeAppleseed")
