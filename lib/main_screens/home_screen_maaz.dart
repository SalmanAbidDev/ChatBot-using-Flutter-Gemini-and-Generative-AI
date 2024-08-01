import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreenMaaz extends StatefulWidget {
  const HomeScreenMaaz({super.key});

  @override
  State<HomeScreenMaaz> createState() => _HomeScreenMaazState();
}

class _HomeScreenMaazState extends State<HomeScreenMaaz> {
  List<Query> _query = [];
  bool img = false;
  String? output;
  String? input;
  String? finalInput;
  File? imgFile;
  TextEditingController _inputController = TextEditingController();
  final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: "YOUR_API_KEY");

  Future<void> inputText(String input) async {
    final content = [Content.text(input)];
    final response = await model.generateContent(content);
    setState(() {
      output = response.text;
      var item = Query(
        input: finalInput!,
        output: output!,
        img: imgFile,
      );
      _query.add(item);
    });
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imgFile = File(pickedFile.path);
        img = true;
        log('Image selected: ${pickedFile.path}');
      });
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
      Content.multi([prompt, ...imageParts])
    ]);

    setState(() {
      output = response.text;
      var item = Query(
        input: finalInput!,
        output: output!,
        img: imgFile,
      );
      _query.add(item);
      img = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: Container(
          color: Colors.blueGrey.shade100,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _query.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5,left: 10,bottom: 5,right: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _query[index].img == null
                                          ? Container()
                                          : Image.file(
                                        _query[index].img!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_query[index].input),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  "https://static.vecteezy.com/system/resources/thumbnails/000/439/863/small/Basic_Ui__28186_29.jpg",
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  "https://external-preview.redd.it/how-to-access-google-gemini-on-your-phone-if-you-dont-have-v0-4sEBYpHgYoR0jS0SQ5LPqC4Ugu0oEjeXovEMz36nW5M.jpg?width=1080&crop=smart&auto=webp&s=1cb4ab70407c82fd14a20b91c717ec10af74f087",
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5,left: 5,bottom: 5,right: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(top: 20,left: 20),
                                    margin: const EdgeInsets.all(2),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(_query[index].output),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        onChanged: (value) {
                          input = value;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          fillColor: Colors.grey[100],
                          filled: true,
                          hintText: "Enter the prompt, for img (also)...",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                          labelText: "Enter your Prompt",
                          labelStyle: const TextStyle(color: Colors.black, fontSize: 12),
                          floatingLabelBehavior: FloatingLabelBehavior.auto, // Floating label behavior
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),


                    ),
                    IconButton(
                      onPressed: () async {
                        await getImage();
                      },
                      icon: const Icon(Icons.attach_file),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blue),
                        foregroundColor:
                        MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _inputController.clear();
                        finalInput = input;
                        input = null;

                        setState(() {});

                        if (img) {
                          readImage(finalInput ?? "");
                        } else {
                          imgFile = null;
                          inputText(finalInput ?? "");
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}

class Query {
  String input;
  String output;
  File? img;
  Query({required this.input, required this.output, this.img});
}
