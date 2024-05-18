// To parse this JSON data, do
//
//     final getUserModel = getUserModelFromJson(jsonString);

import 'dart:convert';

import 'package:chat_app_socket_flutter/models/user_model.dart';

GetUserModel getUserModelFromJson(String str) =>
    GetUserModel.fromJson(json.decode(str));

String getUserModelToJson(GetUserModel data) => json.encode(data.toJson());

class GetUserModel {
  bool? success;
  List<User>? user;

  GetUserModel({
    this.success,
    this.user,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) => GetUserModel(
        success: json["success"],
        user: json["user"] == null
            ? []
            : List<User>.from(json["user"]!.map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "user": user == null
            ? []
            : List<dynamic>.from(user!.map((x) => x.toJson())),
      };
}
