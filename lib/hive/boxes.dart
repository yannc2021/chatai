import 'package:hive/hive.dart';
import 'package:chatai/constants/constants.dart';
import 'package:chatai/hive/chat_history.dart';
import 'package:chatai/hive/settings.dart';
import 'package:chatai/hive/user_model.dart';

class Boxes {
  // get the chat history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  // get settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
