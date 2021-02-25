import 'package:flutter/material.dart';

import '../pages/polls_page.dart';
import '../helper/shared_prefs.dart';
import '../services/database_service.dart';
import '../pages/partners_page.dart';
import '../pages/auth/authenticate_page.dart';
import '../pages/group_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();
  //bool _isSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        children: <Widget>[
          Icon(Icons.account_circle, size: 100.0, color: Colors.red),
          SizedBox(height: 15.0),
          Text(sharedPrefs.getName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 7.0),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()));
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.person),
            title: Text('Chats'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => GroupPage()));
            },
            //selected: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.group),
            title: Text('Groups'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => PollsPage()),
              );
            },
            //selected: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.how_to_vote),
            title: Text('Polls'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    profileName: sharedPrefs.getName,
                    email: sharedPrefs.getEmail,
                  ),
                ),
              );
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => PartnersPage()));
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.thumb_up),
            title: Text('Recommended'),
          ),
          ListTile(
            onTap: () async {
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthenticatePage()),
                  (Route<dynamic> route) => false);
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
