import 'package:flutter/material.dart';

class ProviderServices extends ChangeNotifier {
  String _senderId = '';
  String get senderId => _senderId;

  void getSenderId(String id) {
    _senderId = id;
    notifyListeners();
  }

  Map<String, bool> _onlineStatus = {};
  Map<String, bool> get onlineStatus => _onlineStatus;

  void getStatus(String userId, bool isOnline) {
    _onlineStatus[userId] = isOnline;
    notifyListeners();
  }
}
