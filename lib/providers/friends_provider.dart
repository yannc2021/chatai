import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chatai/models/personality.dart'; 

class FriendsProvider with ChangeNotifier {
  List<Personality> _friends = [];

  List<Personality> get friends => _friends;

  Future<void> loadFriends() async {
    final url = Uri.parse(
      'https://kissengerai-api.onrender.com/api/personalities',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _friends = List<Personality>.from(
          data['personalities'].map((json) => Personality.fromJson(json)),
        );

        notifyListeners();
      } else {
        throw Exception('Failed to load friends: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error loading friends: $error');
    }
  }
}
