import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../helper/shared_prefs.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return (user != null) ? User(uid: user.uid) : null;
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      // Create a new document for the user with uid
      await DatabaseService(uid: user.uid)
          .setUserData(fullName, email, password);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with facebook
  Future<AuthCredential> signInWithFacebook() async {
    FacebookLogin facebookLogin = FacebookLogin();
    FacebookLoginResult facebookLoginResult =
        await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.cancelledByUser:
        print("Cancelled");
        break;
      case FacebookLoginStatus.error:
        print("error");
        break;
      case FacebookLoginStatus.loggedIn:
        print("Logged In");
        break;
    }

    final accessToken = facebookLoginResult.accessToken.token;
    if (facebookLoginResult.status == FacebookLoginStatus.loggedIn)
      return FacebookAuthProvider.getCredential(accessToken: accessToken);
    else
      return null;
  }

  // sign in with google
  Future<AuthCredential> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser =
        await googleSignIn.signIn(); // sign in user
    GoogleSignInAuthentication googleAuthentication =
        await googleUser.authentication;

    return GoogleAuthProvider.getCredential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);
  }

  //sign out
  Future signOut() async {
    try {
      sharedPrefs.saveLoggedIn = false;
      sharedPrefs.saveName = '';
      sharedPrefs.saveEmail = '';

      return await _auth.signOut().whenComplete(() async {
        print("Logged out");
        print("Logged in: ${sharedPrefs.getLoggedIn}");
        print("Email: ${sharedPrefs.getName}");
        print("Full Name: ${sharedPrefs.getEmail}");
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // reset user password
  Future resetPassword(String email) async {
    _auth.sendPasswordResetEmail(email: email).then((value) {
      print('Reset password link sent');
    }).catchError((error) {
      throw error;
    });
  }

  // verify user email address
  Future sendVerifyEmail() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    firebaseUser.sendEmailVerification().then((_) {
      print('Email verification link sent');
    }).catchError((error) {
      throw error;
    });
  }
}
