import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({Key? key}) : super(key: key);

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  late CameraController _cameraController;
  late Future<void> _cameraInitializer;
  late TextRecognizer _textRecognizer;
  FlutterTts flutterTts = FlutterTts();
  String _recognizedText = '';
  String findBiggestDate(String text) {
    text = text.replaceAll(" ", "");
    // Regular expressions to match different date formats
    RegExp dateRegex = RegExp(
        r'\d{2}-\d{2}-\d{4}|\d{4}-\d{2}-\d{2}|\d{4}.\d{2}.\d{2}|\d{2}/\d{2}/\d{4}|\d{4}/\d{2}/\d{2}|\d{2}.\d{2}.\d{4}');

    // Extract dates from the text
    List<DateTime> dates = [];
    dateRegex.allMatches(text).forEach((match) {
      String dateStr = match.group(0)!;
      DateTime? date = parseDate(dateStr);
      if (date != null) {
        dates.add(date);
      }
    });

    if (dates.isEmpty) {
      //print("No dates found in the text.");
      return "No dates found in the text.";
    }

    // Find the biggest date
    DateTime biggestDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    // Format the biggest date
    String formattedDate = formatDate(biggestDate);

    // Print the result
    //print("The expiration date is $formattedDate.");
    return "The expiration date is $formattedDate.";
  }

  DateTime? parseDate(String dateString) {
    List<String> formats = [
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'yyyy.MM.dd',
      'dd.MM.yyyy',
      'dd/MM/yyyy',
      'yyyy/MM/dd'
    ];

    for (String format in formats) {
      try {
        return DateFormat(format).parseStrict(dateString);
      } catch (e) {
        // Date parsing failed for this format, continue to the next one
        continue;
      }
    }

    // Date parsing failed for all formats
    return null;
  }

  String formatDate(DateTime date) {
    String ordinalDay = DateFormat('d').format(date) +
        getOrdinalIndicator(int.parse(DateFormat('d').format(date)));
    String dayOfWeek = DateFormat('EEEE').format(date);
    String monthName = DateFormat('MMMM').format(date);
    String year = DateFormat('yyyy').format(date);

    return "$ordinalDay $dayOfWeek $monthName $year";
  }

  String getOrdinalIndicator(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTextRecognizer();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initializeTextRecognizer() async {
    _textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  // Future<void> _scanText() async {
  //   if (!_cameraController.value.isInitialized) {
  //     return;
  //   }

  //   try {
  //     // Capture a frame from the camera preview
  //     final image = await _cameraController.takePicture();
  //     final inputImage = InputImage.fromFilePath(image.path);

  //     // Process the image to recognize text
  //     final processedImage = await _textRecognizer.processImage(inputImage);

  //     // Get the recognized text
  //     String text = '';
  //     for (TextBlock block in processedImage.blocks) {
  //       for (TextLine line in block.lines) {
  //         text += line.text + ' ';
  //       }
  //     }

  //     setState(() {
  //       _recognizedText = text;
  //     });
  //   } catch (e) {
  //     print('Error scanning text: $e');
  //   }
  // }

  Future<void> _scanText() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    try {
      // Capture a frame from the camera preview
      _cameraController.setFlashMode(FlashMode.off);
      final image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // Process the image to recognize text
      final processedImage = await _textRecognizer.processImage(inputImage);

      // Get the recognized text
      String text = '';
      for (TextBlock block in processedImage.blocks) {
        for (TextLine line in block.lines) {
          text += line.text + ' ';
        }
      }
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      try {
        // Retrieve the document snapshot from Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Retrieve the 'toxic' array from the document data
        List<String> toxicArray =
            (snapshot.data() as Map<String, dynamic>)['toxic'].cast<String>();

        // Check if any of the words in the image are toxic

        bool isToxic = false;
        String toxicList = "";
        List<String> words = text.split(" ");
        for (String word in words) {
          //print(word);

          if (toxicArray.contains(word.toLowerCase())) {
            toxicList = toxicList + word + " ";
          }
        }
        // print(toxicList);
        // print(toxicArray);
        // print(words);
        if (toxicList != "") {
          bool? vibrateOK = await Vibration.hasVibrator();
          if (vibrateOK!) {
            Vibration.vibrate(
              duration: 1000,
            );
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Allerginic Ingredients Found'),
              content: Text(toxicList),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        //print('Error retrieving user toxic array: $e');
      }

      setState(() {
        _recognizedText = text;
      });
    } catch (e) {
      print('Error scanning text: $e');
    }
  }

  Future<void> _scanDate() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    try {
      // Capture a frame from the camera preview
      _cameraController.setFlashMode(FlashMode.off);
      final image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);

      // Process the image to recognize text
      final processedImage = await _textRecognizer.processImage(inputImage);

      // Get the recognized text
      String text = '';
      for (TextBlock block in processedImage.blocks) {
        for (TextLine line in block.lines) {
          text += line.text + ' ';
        }
      }

      setState(() {
        _recognizedText = text;
      });
      await speak(findBiggestDate(text));
    } catch (e) {
      print('Error scanning text: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan the text"),
      ),
      body: Container(
        height: 1000,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/backblue.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        height: 450,
                        width: 300,
                        child: _cameraController.value.isInitialized
                            ? CameraPreview(_cameraController)
                            : Container(),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          minimumSize:
                              MaterialStateProperty.all(const Size(200, 40)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.black,
                          ),
                        ),
                        onPressed: _scanText,
                        child: const Text(
                          "Scan ingredients",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          minimumSize:
                              MaterialStateProperty.all(const Size(200, 40)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.black,
                          ),
                        ),
                        onPressed: _scanDate,
                        child: const Text(
                          "Scan Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _recognizedText,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
