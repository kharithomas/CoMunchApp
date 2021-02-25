import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefs = SharedPrefs();
const String userLoggedInKey = "ISLOGGEDIN";
const String userNameKey = "USERNAMEKEY";
const String userEmailKey = "USEREMAILKEY";

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  // saving data to sharedpreference
  set saveLoggedIn(bool isUserLoggedIn) {
    _sharedPrefs.setBool(userLoggedInKey, isUserLoggedIn);
  }

  set saveName(String userName) {
    _sharedPrefs.setString(userNameKey, userName);
  }

  set saveEmail(String userEmail) {
    _sharedPrefs.setString(userEmailKey, userEmail);
  }

  // fetching data from sharedpreference
  bool get getLoggedIn => _sharedPrefs.getBool(userLoggedInKey);
  String get getName => _sharedPrefs.getString(userNameKey);
  String get getEmail => _sharedPrefs.getString(userEmailKey);
}
