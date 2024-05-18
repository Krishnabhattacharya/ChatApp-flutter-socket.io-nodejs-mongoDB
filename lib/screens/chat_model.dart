// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  bool? success;
  Chat? chat;

  ChatModel({
    this.success,
    this.chat,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        success: json["success"],
        chat: json["chat"] == null ? null : Chat.fromJson(json["chat"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "chat": chat?.toJson(),
      };
}

class Chat {
  String? senderId;
  String? reciverId;
  String? message;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Chat({
    this.senderId,
    this.reciverId,
    this.message,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        senderId: json["senderId"],
        reciverId: json["reciverId"],
        message: json["message"],
        id: json["_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "reciverId": reciverId,
        "message": message,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
