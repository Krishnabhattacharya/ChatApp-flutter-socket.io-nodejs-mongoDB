import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app_socket_flutter/models/get_all_user_model.dart';
import 'package:chat_app_socket_flutter/models/user_model.dart';
import 'package:chat_app_socket_flutter/screens/chat_model.dart';
import 'package:chat_app_socket_flutter/services/ApiServices/ApiBaseServices.dart';
import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
import 'package:chat_app_socket_flutter/utils/dio_error.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

class Apiservices {
  static Future<bool> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    bool res = false;
    UserModel node = UserModel();
    try {
      print("hello");
      final response = await ApiBaseServices.loginUser(
        Exturl: "/auth/login",
        email: email,
        password: password,
      );
      print("heloo");
      print(jsonEncode(response.data));
      if (response.statusCode == 201 || response.statusCode == 200) {
        node = userModelFromJson(jsonEncode(response.data));
        SharedServices.setLoginDetails(node);

        res = true;
      }
      return res;
    } catch (e) {
      if (e is DioException) {
        final errorMessage = DioErrorHandling.handleDioError(e);
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage.toString())));
        });
      } else {
        log("Exception: $e");
      }
      return false;
    }
  }

//---------------------------------------------------------------------------------------------------------
//signup-user
  static Future<bool> signupUser({
    required String name,
    required String email,
    required String password,
    required File filepath,
    required BuildContext context,
  }) async {
    bool isSign = false;

    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'image': await MultipartFile.fromFile(filepath.path, filename: name),
      });

      Response res = await ApiBaseServices.postRequestWithFile(
        endPoint: "/auth/register",
        body: formData,
      );

      log("Response Data: ${res.data}");
      log(res.statusCode.toString());

      if (res.statusCode == 201) {
        isSign = true;
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage = DioErrorHandling.handleDioError(e);
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage.toString())));
        });
      } else {
        log("Exception: $e");
      }

      isSign = false;
    }
    return isSign;
  }

  static Future<List<User>> getAllUser(BuildContext context, String id) async {
    List<User> users = [];
    try {
      final res = await ApiBaseServices.getRequestWithHeaders(
          endPoint: "/auth/getAllUsersExceptCurrent/$id");
      if (res.statusCode == 200) {
        GetUserModel usersList = getUserModelFromJson(jsonEncode(res.data));
        users = usersList.user!;
        //  log(users.toString());
      }
      return users;
    } catch (e) {
      if (e is DioException) {
        final errorMessage = DioErrorHandling.handleDioError(e);
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage.toString())));
        });
      } else {
        log("Exception: $e");
      }
    }
    return users;
  }

  //---------------
  static Future<ChatModel> chatRes(
      BuildContext context, String rID, String sID, String msg) async {
    ChatModel chatList = ChatModel();
    try {
      final res = await ApiBaseServices.postRequest(
          endPoint: "/save-chat",
          body: {"senderId": sID, "reciverId": rID, "message": msg});
      if (res.statusCode == 200) {
        chatList = chatModelFromJson(jsonEncode(res.data));
        log(chatList.chat!.message.toString());
      }
    } catch (e) {
      if (e is DioException) {
        final errorMessage = DioErrorHandling.handleDioError(e);
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage.toString())));
        });
      } else {
        log("Exception: $e");
      }
    }
    return chatList;
  }
}
