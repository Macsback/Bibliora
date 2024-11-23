import 'package:bibliora/service/config_manager.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int _userID = ConfigManager.getConfigValue('USER_ID');
  int get userID => _userID;

  void setUserId(int id) {
    _userID = id;
    notifyListeners();
  }
}
