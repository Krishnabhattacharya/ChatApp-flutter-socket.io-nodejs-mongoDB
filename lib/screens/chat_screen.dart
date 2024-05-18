import 'package:chat_app_socket_flutter/services/ApiServices/api_services.dart.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_socket_flutter/models/user_model.dart';
import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final User user;
  final bool isOnline;
  final IO.Socket socket;
  const ChatScreen({
    Key? key, // Add 'key' parameter here
    required this.user,
    required this.isOnline,
    required this.socket,
  }) : super(key: key); // Initialize super with 'key'

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController t1 = TextEditingController();
  List<Map<String, String>> sentMessages =
      []; // Messages sent by the current user
  List<Map<String, String>> receivedMessages =
      []; // Messages received from other users

  @override
  void initState() {
    super.initState();
    getOldMessage();
    widget.socket.on('reciverMessage', (data) {
      if (mounted) {
        setState(() {
          receivedMessages
              .add({'message': data['message'], 'senderId': data['senderId']});
        });
      }
    });
  }

  void getOldMessage() {
    widget.socket.emit("getoldMessage", {
      "senderId": SharedServices.getLoginDetails()!.user!.id.toString(),
      "reciverId": widget.user.id.toString(),
    });

    widget.socket.on("loadOldMessage", (data) {
      if (this.mounted) {
        // Check if the widget is mounted before calling setState
        if (data.containsKey('chats')) {
          List<dynamic> chats = data['chats'];
          setState(() {
            chats.forEach((chat) {
              if (chat['senderId'] ==
                  SharedServices.getLoginDetails()!.user!.id.toString()) {
                sentMessages.add({
                  'message': chat['message'],
                  'senderId': chat['senderId'],
                });
              } else {
                receivedMessages.add({
                  'message': chat['message'],
                  'senderId': chat['senderId'],
                });
              }
            });
          });
        } else {
          // Handle error here, such as showing a toast or logging the error
          print("Error: Failed to load old messages");
        }
      }
    });
  }

  @override
  void dispose() {
    widget.socket.off('reciverMessage');
    super.dispose();
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      final senderId = SharedServices.getLoginDetails()!.user!.id.toString();
      final messageData = {
        'senderId': senderId,
        'receiverId': widget.user.id.toString(),
        'message': message,
      };

      widget.socket.emit('sendMessage', messageData);
      setState(() {
        sentMessages.add({
          'message': message,
          'senderId': senderId,
        });
        t1.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SharedServices.getLoginDetails()!.user!.id.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name!),
        actions: [
          CircleAvatar(
            radius: 10,
            backgroundColor: widget.isOnline ? Colors.green : Colors.grey,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sentMessages.length + receivedMessages.length,
              itemBuilder: (context, index) {
                if (index < sentMessages.length) {
                  // Display sent messages
                  final isSentByCurrentUser =
                      sentMessages[index]['senderId'] == currentUserId;
                  return Align(
                    alignment: isSentByCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSentByCurrentUser
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        sentMessages[index]['message']!,
                        style: TextStyle(
                          color:
                              isSentByCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Display received messages
                  final isSentByCurrentUser =
                      receivedMessages[index - sentMessages.length]
                              ['senderId'] ==
                          currentUserId;
                  return Align(
                    alignment: isSentByCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSentByCurrentUser
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        receivedMessages[index - sentMessages.length]
                            ['message']!,
                        style: TextStyle(
                          color:
                              isSentByCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: t1,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (t1.text.isNotEmpty) {
                      Apiservices.chatRes(
                        context,
                        widget.user.id.toString(),
                        SharedServices.getLoginDetails()!.user!.id.toString(),
                        t1.text,
                      );
                      sendMessage(t1.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
