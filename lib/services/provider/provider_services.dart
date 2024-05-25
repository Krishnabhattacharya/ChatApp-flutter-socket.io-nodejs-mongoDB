import 'dart:developer';
import 'dart:typed_data';
import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
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

  List<Map<String, dynamic>> _sentMessages = [];
  List<Map<String, dynamic>> _receivedMessages = [];
  List<Map<String, dynamic>> get sentMessages => _sentMessages;
  List<Map<String, dynamic>> get receivedMessages => _receivedMessages;

  void loadOldMessages(Map<String, dynamic> data) {
    if (data.containsKey('chats')) {
      List<dynamic> chats = data['chats'];
      for (var chat in chats) {
        if (chat['senderId'] == senderId) {
          _sentMessages.add({
            'message': chat['message'],
            'senderId': chat['senderId'],
            'createdAt': chat['createdAt'],
            'image': chat['image'],
          });
        } else {
          _receivedMessages.add({
            'message': chat['message'],
            'senderId': chat['senderId'],
            'createdAt': chat['createdAt'],
            'image': chat['image'],
          });
        }
      }
      notifyListeners();
    } else {
      log("Error: Failed to load old messages");
    }
  }

  void sendMessage(String message, String receiverId, {Uint8List? image}) {
    if (message.isNotEmpty || image != null) {
      final senderId = SharedServices.getLoginDetails()!.user!.id.toString();

      final messageData = {
        'message': message,
        'senderId': senderId,
        'receiverId': receiverId,
        'createdAt': DateTime.now().toString(),
        'image': image,
      };

      _sentMessages.add(messageData);
      notifyListeners();
    }
  }

  void receiveMessage(Map<String, dynamic> messageData) {
    final currentUserId = SharedServices.getLoginDetails()!.user!.id.toString();
    if (messageData.containsKey('message') &&
        messageData.containsKey('senderId') &&
        messageData.containsKey('receiverId') &&
        messageData['receiverId'] == currentUserId) {
      _receivedMessages.add({
        'message': messageData['message'],
        'senderId': messageData['senderId'],
        'createdAt': DateTime.now().toString(),
        'image': messageData['image'],
      });
      notifyListeners();
    }
  }
}
