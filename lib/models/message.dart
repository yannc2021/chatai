import 'dart:convert';

class Message {
  final String messageId;
  final String chatId;
  final String content; // The content of the message (text or special event like kiss)
  final DateTime timeSent;
  final bool kissEvent; // Added field to track whether it's a kiss event

  Message({
    required this.messageId,
    required this.chatId,
    required this.content,
    required this.timeSent,
    this.kissEvent = false, // Default value is false, can be set to true for kiss events
  });

  // Convert a Message object into a Map
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'content': content,
      'timeSent': timeSent.toIso8601String(),
      'kissEvent': kissEvent, // Include kissEvent in the map
    };
  }

  // Create a Message object from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      chatId: map['chatId'],
      content: map['content'],
      timeSent: DateTime.parse(map['timeSent']),
      kissEvent: map['kissEvent'] ?? false, // Default to false if not provided
    );
  }

  // Convert the Message object to a JSON string
  String toJson() => json.encode(toMap());

  // Create a Message object from a JSON string
  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}
