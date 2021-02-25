/// TODO: Fix pop refresg bug and handle name changing properly

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/auth_service.dart';
import '../../helper/shared_prefs.dart';
import '../../services/database_service.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // variables
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isNameValid = true;
  var _isEmailValid = true;
  var _isLoading = false;
  var _initValues = {
    'fullName': '',
    'email': '',
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _nameController.text = sharedPrefs.getName;
    _emailController.text = sharedPrefs.getEmail;
    setState(() {
      _isLoading = false;
    });
  }

  // update user profile
  updateProfileData() async {
    setState(() {
      _nameController.text.trim().length < 3 || _nameController.text.isEmpty
          ? _isNameValid = false
          : _isNameValid = true;
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(_emailController.text.trim())
          ? _isEmailValid = true
          : _isEmailValid = false;
    });

    if (_isNameValid && _isEmailValid) {
      setState(() {
        _isLoading = true;
      });

      // update firebase email here too
      //AuthService _authService = AuthService();
      //_authService.resetEmail(_email);

      // update firestore user
      FirebaseUser _user = await FirebaseAuth.instance.currentUser();
      DatabaseService _databaseService = DatabaseService(uid: _user.uid);
      await _databaseService.updateUserData(
        fullName: _nameController.text,
        email: _emailController.text,
      );

      // update shared preferences
      sharedPrefs.saveName = _nameController.text;
      sharedPrefs.saveEmail = _emailController.text;

      setState(() {
        _isLoading = false;
      });

      //Navigator.pop(context, true);

      Fluttertoast.showToast(msg: 'Profile updated!');
    }
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
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 23.0,
          ),
        ),

        //backgroundColor: Colors.black87,
        elevation: 0.0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.account_circle,
                        size: 200.0, color: Colors.grey[700]),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Update Name",
                        errorText:
                            _isNameValid ? null : "Display Name too short",
                      ),
                    ),
                    Divider(height: 20.0),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Update Email",
                        errorText: _isEmailValid ? null : "Email not valid",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      child: FlatButton(
                        color: Colors.red,
                        onPressed: updateProfileData,
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // Divider(height: 20.0),
                    // TextFormField(
                    //   initialValue: _initValues['bio'],
                    //   decoration:
                    //       InputDecoration(labelText: 'Bio (max. 25 words)'),
                    //   autocorrect: false,
                    //   validator: (val) {
                    //     if (val.isEmpty) {
                    //       return 'Please provide a val';
                    //     }
                    //     if (val.length > 25) {
                    //       return 'Bio must not exceed 25 words';
                    //     }
                    //   },
                    //   onSaved: (val) {
                    //     _fullNameController.text = val;
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
