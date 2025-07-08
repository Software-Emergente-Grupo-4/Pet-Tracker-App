import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final KeyValueStorageService storageService;
  static const String aiProfilePicPath =
      'assets/images/pet_tracker_ai_assistant.png';
  ChatUser? user;
  bool isSending = false;
  List<ChatUser> typingUsers = [];

  final ChatUser aiUser = ChatUser(
    id: 'AI',
    firstName: 'Pet Tracker',
    lastName: 'AI',
    profileImage: aiProfilePicPath,
  );

  List<ChatMessage> messages = <ChatMessage>[
    ChatMessage(
      text:
          "Hi, I'm Pet Tracker AI, your virtual assistant for all things pet-related! How can I help you today?",
      user: ChatUser(
        id: 'AI',
        firstName: 'Pet Tracker',
        lastName: 'AI',
        profileImage: aiProfilePicPath,
      ),
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    storageService = ref.read(keyValueStorageServiceProvider);
    final userId = await storageService.getValue<String>('userId');
    if (userId == null) {
      print('>>> User ID not found');
      throw Exception('User ID not found');
    }

    setState(() {
      user = ChatUser(
        id: userId,
        firstName: 'You',
      );
    });
  }

  Future<void> _handleSend(ChatMessage message) async {
    setState(() {
      isSending = true;
      messages.insert(0, message);
      typingUsers = [aiUser];
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://pet-tracker-chatbot.azurewebsites.net/api/pet_tracker_chabot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "chat": messages.reversed
              .map((m) => {
                    "role": m.user.id == user!.id ? "user" : "model",
                    "text": m.text
                  })
              .toList(),
          "new_message": {
            "role": "user",
            "text": message.text,
          }
        }),
      );

      final String replyText = response.body;

      final ChatMessage aiMessage = ChatMessage(
          text: replyText,
          user: aiUser,
          createdAt: DateTime.now(),
          isMarkdown: true);

      setState(() {
        messages.insert(0, aiMessage);
        isSending = false;
        typingUsers = [];
      });
    } catch (e) {
      setState(() {
        isSending = false;
        typingUsers = [];
      });
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(aiProfilePicPath),
            ),
            SizedBox(width: 10),
            Text(
              'Pet Tracker AI',
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
      body: DashChat(
        currentUser: user!,
        onSend: (ChatMessage message) {
          _handleSend(message);
        },
        messages: messages,
        typingUsers: typingUsers,
      ),
    );
  }
}
