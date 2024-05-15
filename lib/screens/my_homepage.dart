import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController t1 = TextEditingController();
  IO.Socket? socket;
  @override
  void initState() {
    super.initState();
    connection();
  }

  void connection() {
    socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket!.on('message', (message) {
      print('Connected to Socket.IO server! + countupdate  $message');
    });
    socket!.on("sendMessage", (ackData) {
      print("Acknowledgment from server: $ackData");
    });
    socket!.on('disconnect', (msg) {
      print(msg);
    });
    socket!.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all()),
              child: TextField(
                controller: t1,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  socket!.emit(
                    "sendMessage",
                    t1.text,
                  ); //send data to server
                  print("message sent");
                },
                child: const Text("send")),
          ],
        ),
      ),
    );
  }
}
