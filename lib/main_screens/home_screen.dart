import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Gemini gemini = Gemini.instance;
  final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: "AIzaSyBDBL23AwXbLB-EwSifCLUqX7b7KjftJqw");
  List<ChatMessage> messages = [];
  bool img = false;
  File? imgFile;
  ChatUser currentUser =
  ChatUser(id: "0", firstName: "User",
      profileImage: "https://static.vecteezy.com/system/resources/thumbnails/000/439/863/small/Basic_Ui__28186_29.jpg"
  );
  TextEditingController inputController = TextEditingController();
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
      "https://external-preview.redd.it/how-to-access-google-gemini-on-your-phone-if-you-dont-have-v0-4sEBYpHgYoR0jS0SQ5LPqC4Ugu0oEjeXovEMz36nW5M.jpg?width=1080&crop=smart&auto=webp&s=1cb4ab70407c82fd14a20b91c717ec10af74f087");

  get question => null;

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if(chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: response);
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      Text('$e');
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        medias: [
          ChatMedia(url: pickedFile.path, fileName: "", type: MediaType.image)
        ],
        text: "Describe this image?",
      );
    } else {
      log('No image selected');
    }
  }

  Future<void> readImage(String input) async {
    if (imgFile == null) {
      log('No image file available');
      return;
    }

    final prompt = TextPart(input);
    final imageParts = [
      DataPart(
        "image/jpg",
        await imgFile!.readAsBytes(),
      ),
    ];

    final response = await model.generateContent([
      question.multi([prompt, ...imageParts])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    //final height = MediaQuery.sizeOf(context).height * 1;
    //final width = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade400,
        title: const Text(
          'ChatBot',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 28),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
        inputOptions: InputOptions(trailing: [
          IconButton(
            onPressed: () async {
              await _getImage();
            },
            icon: const Icon(Icons.image_outlined),
          )
        ]),
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages);
  }
  /*void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
        text: "Describe this image?",
      );
      _sendMessage(chatMessage);
    }
  }*/
}