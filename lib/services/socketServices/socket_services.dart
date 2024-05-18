import 'package:chat_app_socket_flutter/services/provider/provider_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal(BuildContext context) {
    String id = Provider.of<ProviderServices>(context, listen: false).senderId;
    socket = IO.io('http://10.0.2.2:3000/user-namespace', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'sender_id': id}
    });
    socket!.connect();
  }

  static SocketClient getInstance(BuildContext context) {
    _instance ??= SocketClient._internal(context);
    return _instance!;
  }
}
