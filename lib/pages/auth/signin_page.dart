import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../main_view.dart';
import '../../models/user.dart';
import '../../helper/shared_prefs.dart';
import '../group_page.dart';
import '../home_page.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../shared/constants.dart';
import '../../shared/loading.dart';
import './reset_password_page.dart';

enum LoginType { Google, Facebook }

class SignInPage extends StatefulWidget {
  final Function toggleView;
  SignInPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  //functions
  _onSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .signInWithEmailAndPassword(email, password)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot =
              await DatabaseService().getUserData(email);

          sharedPrefs.saveLoggedIn = true;
          sharedPrefs.saveEmail = email;
          sharedPrefs.saveName = userInfoSnapshot.documents[0].data['fullName'];

          // create new User model from current Firestore user
          currentUser = User.fromDocument(userInfoSnapshot.documents[0]);
          //print(currentUser);
          //print(currentUser.fullName);

          print("Signed In");
          print("Logged in: ${sharedPrefs.getLoggedIn}");
          print("Email: ${sharedPrefs.getName}");
          print("Full Name: ${sharedPrefs.getEmail}");

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainView()));
        } else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xffEAA05D),
                    Color(0xffE74E4D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.only(top: 140),
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 80.0),
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('assets/images/logo.png',
                                height: 53, width: 267),
                            SizedBox(height: 30.0),
                            Text("Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25.0)),
                            SizedBox(height: 20.0),
                            TextFormField(
                              style: TextStyle(color: Colors.white),
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Email'),
                              validator: (val) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val)
                                    ? null
                                    : "Please enter a valid email";
                              },
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                            ),
                            SizedBox(height: 15.0),
                            TextFormField(
                              style: TextStyle(color: Colors.white),
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Password'),
                              validator: (val) => val.length < 6
                                  ? 'Password not strong enough'
                                  : null,
                              obscureText: true,
                              onChanged: (val) {
                                setState(() {
                                  password = val;
                                });
                              },
                            ),
                            SizedBox(height: 20.0),
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: RaisedButton(
                                  elevation: 0.0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  child: Text('Sign In',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0)),
                                  onPressed: () {
                                    _onSignIn();
                                  }),
                            ),
                            SizedBox(height: 10.0),
                            Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Register here',
                                    style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        widget.toggleView();
                                      },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text.rich(
                              TextSpan(
                                text: "Need help logging in? ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Reset password',
                                    style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ResetPasswordPage()),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(error,
                                style: TextStyle(
                                    color: Colors.red, fontSize: 14.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
