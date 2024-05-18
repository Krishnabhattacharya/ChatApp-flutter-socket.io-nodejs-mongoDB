import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app_socket_flutter/models/user_model.dart';
import 'package:chat_app_socket_flutter/screens/chat_screen.dart';
import 'package:chat_app_socket_flutter/screens/login_page.dart';
import 'package:chat_app_socket_flutter/services/ApiServices/api_services.dart.dart';
import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
import 'package:chat_app_socket_flutter/services/provider/provider_services.dart';
import 'package:chat_app_socket_flutter/services/socketServices/socket_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  IO.Socket? socket;
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final senderId = SharedServices.getLoginDetails()!.user!.id!;
      Provider.of<ProviderServices>(context, listen: false)
          .getSenderId(senderId);
      socket = SocketClient.getInstance(context).socket;
      connection();
      getAllUser();
    });
  }

  void connection() {
    socket!.on('connection', (_) {
      print('Connected to user namespace!');
    });
    socket!.on('getOnlineUser', (data) {
      print(data['sender_id'].toString());
      Provider.of<ProviderServices>(context, listen: false)
          .getStatus(data['sender_id'].toString(), true);
    });

    socket!.on('getOfflineStatus', (data) {
      Provider.of<ProviderServices>(context, listen: false)
          .getStatus(data['sender_id'].toString(), false);
    });
    socket!.on('disconnect', (_) {
      print('Disconnected from user namespace');
    });
    socket!.connect();
  }

  void getAllUser() async {
    users = await Apiservices.getAllUser(
        context, SharedServices.getLoginDetails()!.user!.id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hi ${SharedServices.getLoginDetails()!.user!.name}"),
        actions: [
          IconButton(
            onPressed: () {
              SharedServices.logout(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<ProviderServices>(
        builder: (context, provider, _) {
          // final onlineUserIds = provider.onlineStatus.entries
          //     .where((entry) => entry.value)
          //     .map((entry) => entry.key)
          //     .toList();

          // // Print the list of online user IDs
          // print("Online User IDs:");
          // onlineUserIds.forEach((id) {
          //   print(id);
          // });
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i];
              final isOnline = provider.onlineStatus[user.id] ?? false;
              return GestureDetector(
                onTap: () {
                  print(provider.onlineStatus[user.id].toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        socket: socket!,
                        user: users[i],
                        isOnline: isOnline,
                      ),
                    ),
                  );
                },
                child: ListTile(title: Text(users[i].name.toString())),
              );
            },
          );
        },
      ),
    );
  }
}
