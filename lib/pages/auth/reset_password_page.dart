import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/auth_service.dart';
import '../../shared/constants.dart';
import '../../shared/loading.dart';

class ResetPasswordPage extends StatefulWidget {
  final Function toggleView;
  ResetPasswordPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<ResetPasswordPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String email = '';
  String error = '';

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
              child: Container(
                margin: EdgeInsets.only(top: 140),
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/images/logo.png',
                            height: 53, width: 267),
                        SizedBox(height: 30.0),
                        Text("Reset Password",
                            style:
                                TextStyle(color: Colors.white, fontSize: 25.0)),
                        SizedBox(height: 20.0),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration:
                              textInputDecoration.copyWith(labelText: 'Email'),
                          onChanged: (val) {
                            setState(() {
                              email = val;
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
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: Text('Send Reset',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16.0)),
                              onPressed: () {
                                _auth.resetPassword(email);
                                Fluttertoast.showToast(
                                    msg: 'Email Link Sent Successfully!');
                                Navigator.of(context).pop();
                              }),
                        ),
                        SizedBox(height: 10.0),
                        Text(error,
                            style:
                                TextStyle(color: Colors.red, fontSize: 14.0)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
