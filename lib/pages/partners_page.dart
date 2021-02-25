import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../services/database_service.dart';
import '../widgets/partners_tile.dart';

class PartnersPage extends StatefulWidget {
  @override
  _PartnersPageState createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage>
    with AutomaticKeepAliveClientMixin {
  List<DocumentSnapshot> _recommendedUsers = [];
  DatabaseService _databaseService;

  initState() {
    super.initState();
    getRecommendedUsers();
  }

  // gets all recommended users
  getRecommendedUsers() {
    _databaseService = DatabaseService();
    _databaseService.getRecommendedUsers().then((snapshots) {
      setState(() {
        snapshots.documents.forEach((doc) {
          // TODO: add more recommendation logic
          doc.data["fullName"] != null ? _recommendedUsers.add(doc) : print('');
          // if (doc.data["isVegetarian"] != null && doc.data["isVegetarian"]) {
          //   _recommendedUsers.add(doc);
          // }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
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
          'Matches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23.0,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 0.0,
      ),
      drawer: AppDrawer(),
      body: _recommendedUsers != null
          ? _recommendedUsers.length > 0
              ? ListView.builder(
                  itemCount: _recommendedUsers.length,
                  itemBuilder: (context, index) {
                    return PartnersTile(
                      fullName: _recommendedUsers[index].data['fullName'],
                      email: _recommendedUsers[index].data['email'],
                    );
                  })
              : Center(
                  child: Text('You currently have no recommended users',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24)),
                )
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  // Enables persistent data across page views
  bool get wantKeepAlive => true;
}
