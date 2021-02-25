import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../helper/shared_prefs.dart';
import '../../main_view.dart';
import '../group_page.dart';
import '../home_page.dart';
import '../../services/auth_service.dart';
import '../../shared/constants.dart';
import '../../shared/loading.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;
  RegisterPage({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

  // text field state
  String fullName = '';
  String email = '';
  String password = '';
  String error = '';

  // functions
  _onRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .registerWithEmailAndPassword(fullName, email, password)
          .then((result) async {
        if (result != null) {
          sharedPrefs.saveLoggedIn = true;
          sharedPrefs.saveEmail = email;
          sharedPrefs.saveName = fullName;

          // send email verification link
          await _auth.sendVerifyEmail();

          print("Registered");
          print("Logged in: ${sharedPrefs.getLoggedIn}");
          print("Email: ${sharedPrefs.getName}");
          print("Full Name: ${sharedPrefs.getEmail}");

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainView()));
        } else {
          setState(() {
            error = 'Error while registering the user!';
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
              child: Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.only(top: 100),
                    height: MediaQuery.of(context).size.height,
                    //color: Colors.black,
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
                            Text("Register",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25.0)),
                            SizedBox(height: 20.0),
                            TextFormField(
                              style: TextStyle(color: Colors.white),
                              decoration: textInputDecoration.copyWith(
                                  labelText: 'Username'),
                              onChanged: (val) {
                                setState(() {
                                  fullName = val;
                                });
                              },
                            ),
                            SizedBox(height: 15.0),
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
                                  child: Text('Register',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0)),
                                  onPressed: () {
                                    _onRegister();
                                  }),
                            ),
                            SizedBox(height: 10.0),
                            Text.rich(
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.0),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Sign In',
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
                            Text(error,
                                style: TextStyle(
                                    color: Colors.yellow, fontSize: 18.0)),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
          );
  }
}
