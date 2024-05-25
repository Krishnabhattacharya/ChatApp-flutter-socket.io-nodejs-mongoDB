// import 'dart:convert';
// import 'dart:developer';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:chat_app_socket_flutter/models/user_model.dart';
// import 'package:chat_app_socket_flutter/services/ApiServices/api_services.dart.dart';
// import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
// import 'package:chat_app_socket_flutter/services/provider/provider_services.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChatScreen extends StatefulWidget {
//   final User user;
//   final bool isOnline;
//   final IO.Socket socket;
//   const ChatScreen({
//     Key? key,
//     required this.user,
//     required this.isOnline,
//     required this.socket,
//   }) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   TextEditingController t1 = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   ScrollController _scrollController = ScrollController();
//   Uint8List? _imageData; // Add this variable for image data

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addPostFrameCallback((_) {
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     });
//     getOldMessage();
//     widget.socket.on('reciverMessage', (data) {
//       if (mounted) {
//         Provider.of<ProviderServices>(context, listen: false)
//             .receiveMessage(data);
//       }
//     });
//   }

//   void getOldMessage() {
//     widget.socket.emit("getoldMessage", {
//       "senderId": SharedServices.getLoginDetails()!.user!.id.toString(),
//       "reciverId": widget.user.id.toString(),
//     });

//     widget.socket.on("loadOldMessage", (data) {
//       if (this.mounted) {
//         Provider.of<ProviderServices>(context, listen: false)
//             .loadOldMessages(data);
//         WidgetsBinding.instance!.addPostFrameCallback((_) {
//           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//         });
//       }
//     });
//   }

//   Future<void> pickImage() async {
//     try {
//       final imageFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (imageFile != null) {
//         final imageData = await imageFile.readAsBytes();
//         setState(() {
//           _imageData = Uint8List.fromList(imageData);
//         });
//       }
//     } catch (e) {
//       log(e.toString());
//     }
//   }

//   @override
//   void dispose() {
//     widget.socket.off('reciverMessage');
//     super.dispose();
//   }

//   void sendMessage(String message) {
//     if (message.isNotEmpty || _imageData != null) {
//       final senderId = SharedServices.getLoginDetails()!.user!.id.toString();
//       final base64Image = _imageData != null ? base64Encode(_imageData!) : null;

//       final messageData = {
//         'senderId': senderId,
//         'receiverId': widget.user.id.toString(),
//         'message': message,
//         'image': base64Image,
//       };

//       widget.socket.emit('sendMessage', messageData);
//       Provider.of<ProviderServices>(context, listen: false).sendMessage(
//         message,
//         widget.user.id.toString(),
//         image: _imageData, // Pass image data to sendMessage method
//       );

//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       setState(() {
//         t1.clear();
//         _imageData = null;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = SharedServices.getLoginDetails()!.user!.id.toString();
//     final data = context.watch<ProviderServices>();

//     List<Map<String, dynamic>> allMessages = [
//       ...data. data.sentMessages,
//       ...data. data.receivedMessages
//     ];
//     allMessages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.user.name!),
//         actions: [
//           CircleAvatar(
//             radius: 10,
//             backgroundColor: widget.isOnline ? Colors.green : Colors.grey,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: allMessages.length,
//               itemBuilder: (context, index) {
//                 final message = allMessages[index];
//                 final isSentByCurrentUser =
//                     message['senderId'] == currentUserId;
//                 final isForCurrentUser =
//                     message['receiverId'] == currentUserId ||
//                         isSentByCurrentUser;

//                 if (!isForCurrentUser) {
//                   return SizedBox
//                       .shrink(); // Skip rendering if not intended for current user
//                 }

//                 final hasImage = message['image'] != null;
//                 final imageWidget = hasImage
//                     ? (message['image'] is Uint8List
//                         ? Image.memory(message['image'],
//                             width: 150, height: 150)
//                         : Image.network(message['image'],
//                             width: 150, height: 150))
//                     : SizedBox.shrink();

//                 return Align(
//                   alignment: isSentByCurrentUser
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//                     decoration: BoxDecoration(
//                       color:
//                           isSentByCurrentUser ? Colors.blue : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (hasImage) imageWidget,
//                         if (hasImage) SizedBox(height: 8),
//                         Text(
//                           message['message']!,
//                           style: TextStyle(
//                             color: isSentByCurrentUser
//                                 ? Colors.white
//                                 : Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: t1,
//                     decoration: InputDecoration(
//                       hintText: "Type a message",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.image),
//                   onPressed: pickImage,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     sendMessage(t1.text);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:chat_app_socket_flutter/models/chat_model.dart';
import 'package:chat_app_socket_flutter/services/ApiServices/api_services.dart.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_socket_flutter/models/user_model.dart';
import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final User user;
  final bool isOnline;
  final IO.Socket socket;
  const ChatScreen({
    super.key,
    required this.user,
    required this.isOnline,
    required this.socket,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController t1 = TextEditingController();
  List<Map<String, dynamic>> sentMessages = [];
  List<Map<String, dynamic>> receivedMessages = [];
  XFile? imagefile;
  final ImagePicker _picker = ImagePicker();
  final _scrollController = ScrollController();
  bool isSend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    getOldMessage();
    widget.socket.on('reciverMessage', (data) {
      if (mounted) {
        //get the recived message from other user and store in the list
        setState(() {
          receivedMessages.add({
            'message': data['message'],
            'senderId': data['senderId'],
            'createdAt': DateTime.parse(data['createdAt']),
            'image': data['image']
          });
        });
      }
    });
  }

  void getOldMessage() {
    //send the server senderID and reciverID for search the chats and send to the client side

    widget.socket.emit("getoldMessage", {
      "senderId": SharedServices.getLoginDetails()!.user!.id.toString(),
      "reciverId": widget.user.id.toString(),
    });

    widget.socket.on("loadOldMessage", (data) {
      //get the old chats from server and store in the list according to sender and reciver
      if (this.mounted) {
        if (data.containsKey('chats')) {
          List<dynamic> chats = data['chats'];
          setState(() {
            for (var chat in chats) {
              //if senderId same as current user then store in sentMessage list else store recivedmessage list
              if (chat['senderId'] ==
                  SharedServices.getLoginDetails()!.user!.id.toString()) {
                sentMessages.add({
                  'message': chat['message'],
                  'senderId': chat['senderId'],
                  'createdAt': DateTime.parse(chat['createdAt']),
                  'image': chat['image']
                });
              } else {
                receivedMessages.add({
                  'message': chat['message'],
                  'senderId': chat['senderId'],
                  'createdAt': DateTime.parse(chat['createdAt']),
                  'image': chat['image']
                });
              }
            }
          });
        } else {
          log("Error: Failed to load old messages");
        }
      }
    });
  }

  @override
  void dispose() {
    widget.socket
        .off('reciverMessage'); //off the recivedmessage when state is dispose
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imagefile = XFile(image.path);
      });
    }
  }

  void sendMessage(String message, [String? imageUrl]) {
    if (message.isNotEmpty || imageUrl != null) {
      final senderId = SharedServices.getLoginDetails()!.user!.id.toString();
      final messageData = {
        'senderId': senderId,
        'receiverId': widget.user.id.toString(),
        'message': message,
        'image': imageUrl,
        'createdAt': DateTime.now().toIso8601String()
      };

      widget.socket.emit('sendMessage',
          messageData); //send the message to the server and also add to the sendmessage list
      setState(() {
        sentMessages.add({
          'message': message,
          'senderId': senderId,
          'createdAt': DateTime.now(),
          'image': imageUrl
        });
        t1.clear();
        imagefile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SharedServices.getLoginDetails()!.user!.id.toString();
    List<Map<String, dynamic>> allMessages = [
      //make list where sentmessage+recivedmessage
      ...sentMessages,
      ...receivedMessages
    ];
    allMessages.sort((a, b) =>
        a['createdAt'].compareTo(b['createdAt'])); //sort the list based on time

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
              controller: _scrollController,
              itemCount: allMessages.length,
              itemBuilder: (context, index) {
                final message = allMessages[index];
                final isSentByCurrentUser = message['senderId'] ==
                    currentUserId; //chech that mesage is mine or not
                final hasImage = message['image'] != null;
                final imageWidget = hasImage
                    ? Image.network(message['image'], fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      }, width: 150, height: 150)
                    : const SizedBox.shrink(); //if image then show else empty
                return Align(
                  alignment: isSentByCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: message['message'] == ""
                        ? const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10)
                        : const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                    padding: message['message'] == null
                        ? const EdgeInsets.symmetric(vertical: 0, horizontal: 0)
                        : const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 14),
                    decoration: BoxDecoration(
                      color: message['message'] == ""
                          ? null
                          : isSentByCurrentUser
                              ? Colors.blue
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasImage) imageWidget,
                        if (hasImage) const SizedBox(height: 8),
                        if (message['message'] != null &&
                            message['message'].isNotEmpty)
                          Text(
                            message['message']!,
                            style: TextStyle(
                              color: isSentByCurrentUser
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
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
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: isSend
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: () async {
                    setState(() {
                      isSend = true;
                    });
                    ChatModel? res = await Apiservices.chatRes(
                        context,
                        widget.user.id.toString(),
                        SharedServices.getLoginDetails()!.user!.id.toString(),
                        t1.text,
                        t1.text.isNotEmpty && imagefile == null
                            ? null
                            : imagefile);
                    setState(() {
                      isSend = false;
                    });
                    sendMessage(t1.text, res?.chat?.image);
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
