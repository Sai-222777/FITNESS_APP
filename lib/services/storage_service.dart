import 'package:shared_preferences/shared_preferences.dart';

class StorageService{

  static Future<void> storeEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentEmail', email);
  }

  static Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentEmail');
  }

  static Future<void> clearEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentEmail');
  }

  static Future<void> storePassword(String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentPass', pass);
  }

  static Future<String?> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentPass');
  }

  static Future<void> clearPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentPass');
  }

  static Future<void> storePhoto(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentPhoto', path);
  }

  static Future<String?> getPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentPhoto');
  }

  static Future<void> clearPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentPhoto');
  }

}
