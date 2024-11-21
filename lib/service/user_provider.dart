import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int _userID = 1;

  int get userID => _userID;

  void setUserId(int id) {
    _userID = id;
    notifyListeners();
  }
}
