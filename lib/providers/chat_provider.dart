import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:chatai/apis/api_service.dart';
import 'package:chatai/constants/constants.dart';
import 'package:chatai/hive/boxes.dart';
import 'package:chatai/hive/settings.dart';
import 'package:chatai/hive/user_model.dart';
import 'package:chatai/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  final List<Message> _inChatMessages = [];
  int _currentIndex = 0;
  String _currentChatId = '';
  bool _isLoading = false;
  String? selectedPersonalityId;

  List<Message> get inChatMessages => _inChatMessages;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String get currentChatId => _currentChatId;

  void setSelectedPersonality(String personalityId) {
    selectedPersonalityId = personalityId;
    notifyListeners();
  }

  void addMessage(Message message) {
    _inChatMessages.add(message);
    notifyListeners();
  }

  Future<void> setInChatMessages({required String chatId}) async {
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);
    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');
    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      return Message.fromMap(Map<String, dynamic>.from(message));
    }).toList();
    notifyListeners();
    return newData;
  }

  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> deleteChatMessages({required String chatId}) async {
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    }
    await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
    await Hive.box('${Constants.chatMessagesBox}$chatId').close();

    if (currentChatId.isNotEmpty && currentChatId == chatId) {
      setCurrentChatId(newChatId: '');
      _inChatMessages.clear();
      notifyListeners();
    }
  }

  Future<void> prepareChatFromFriend(String personalityId) async {
    final chatId = const Uuid().v4();
    _inChatMessages.clear();
    setCurrentChatId(newChatId: chatId);
    setSelectedPersonality(personalityId);
  }

  Future<void> prepareChatFromHistory(String chatID) async {
    final chatHistory = await loadMessagesFromDB(chatId: chatID);
    _inChatMessages.clear();
    _inChatMessages.addAll(chatHistory);
    setCurrentChatId(newChatId: chatID);
  }

  Future<void> sentMessage({required String message, required bool isTextOnly, required bool kissEvent}) async {
    await setModel(isTextOnly: isTextOnly);

    if (selectedPersonalityId == null) {
      log('No personality selected');
      setLoading(value: false);
      return;
    }

    try {
      setLoading(value: true);

      final chatId = getChatId();
      final userMessage = Message(
        messageId: const Uuid().v4(),
        chatId: chatId,
        content: message,
        timeSent: DateTime.now(),
        kissEvent: kissEvent, // Pass the kissEvent flag
      );
      addMessage(userMessage);

      final uri = Uri.parse('${Constants.baseUrl}/api/chat/$selectedPersonalityId');
      final requestBody = jsonEncode({
        'message': message,
        'kiss_event': kissEvent, // Include the kiss_event in the API request
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final assistantMessage = Message(
          messageId: const Uuid().v4(),
          chatId: chatId,
          content: responseData['response'],
          timeSent: DateTime.now(),
          kissEvent: false, // No kiss event for the assistant's message
        );
        addMessage(assistantMessage);
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      setLoading(value: false);
    }
  }

  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    await messagesBox.add(userMessage.toMap());
    await messagesBox.add(assistantMessage.toMap());

    final chatHistoryBox = Boxes.getChatHistory();
    await messagesBox.close();
  }

  String getChatId() {
    return currentChatId.isEmpty ? const Uuid().v4() : currentChatId;
  }
}
