import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.purple[500],
      ),
      home: const Test(title: 'Image Generator'),
    );
  }
}

class Test extends StatefulWidget {
  final String title;
  const Test({Key? key, required this.title}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final TextEditingController _queryController = TextEditingController();
  final StabilityAI _ai = StabilityAI();

  final String apiKey = 'sk-ZqppGSikRUpGCbz7LoeaLdaJZiOvqnCrKgEirYkn2P1TmYh3';

  final ImageAIStyle imageAIStyle = ImageAIStyle.cartoon;

  bool run = false;

  Future<Uint8List> _generate(String query) async {
    Uint8List image = await _ai.generateImage(
      apiKey: apiKey,
      imageAIStyle: imageAIStyle,
      prompt: query,
    );
    return image;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// The size of the container for the generated image.
    final double size = Platform.isAndroid || Platform.isIOS
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height / 2;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    border: Border.all(
                      width: 0.5,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'What image do you want to generate ?',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextButton(
                    onPressed: () {
                      String query = _queryController.text;
                      if (query.isNotEmpty) {
                        setState(() {
                          run = true;
                        });
                      } else {
                        if (kDebugMode) {
                          print('Query is empty !!');
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.purple[400]),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                    ),
                    child: const Text(
                      'Generate',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: size,
                    width: size,
                    child: run
                        ? FutureBuilder<Uint8List>(
                            future: _generate(_queryController.text),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(snapshot.data!),
                                );
                              } else {
                                return Container();
                              }
                            },
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
