import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String userLoggedinKey = "LOGGED_IN_KEY";
  static String userNameKey = "USER_NAME_KEY";
  static String userEmailKey = "USER_EMAIL_KEY";

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedinKey);
  }

  static Future<bool?> saveUserLoggedInStatus(isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(userLoggedinKey, isUserLoggedIn);
  }

  static Future<bool?> saveUserName(name) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKey, name);
  }

  static Future<bool?> saveUserEmail(email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKey, email);
  }
}
