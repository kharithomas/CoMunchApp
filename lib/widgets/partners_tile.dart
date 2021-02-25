import 'package:flutter/material.dart';

import '../pages/profile_page.dart';

class PartnersTile extends StatelessWidget {
  final String fullName;
  final String email;

  PartnersTile({this.fullName, this.email});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.red,
          child: Text(fullName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)),
        ),
        //contentPadding: EdgeInsets.all(0),
        title: Text(fullName),
        subtitle: Text(email),
        trailing: FlatButton(
          child: Text(
            "View",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Colors.grey,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  profileName: fullName,
                  email: email,
                ),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                profileName: fullName,
                email: email,
              ),
            ),
          );
        },
      ),
    );
  }
}
