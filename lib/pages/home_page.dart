import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import 'package:vibration/vibration.dart';

import '../widgets/tab_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  late Future<void>? _initializeControllerFuture;
  bool _isButtonPressed = false;
  bool _isSettingsButtonPressed = false;
  bool _isFlashOn = false;
  bool _isprocessing = false;
  bool _expirySelected = false;
  FlutterTts flutterTts = FlutterTts();

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
    // Get the available cameras
    _initializeControllerFuture = availableCameras().then((cameras) {
      if (cameras.isNotEmpty) {
        // Select the first available camera
        _controller = CameraController(cameras[0], ResolutionPreset.veryHigh);
        return _controller.initialize();
      } else {
        // Handle case when no cameras are available

        throw 'No cameras available.';
      }
    }).catchError((error) {
      // Handle camera initialization errors

      throw 'Error initializing camera: $error';
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    try {
      if (_isFlashOn) {
        await _controller.setFlashMode(FlashMode.off);
        setState(() {
          _isFlashOn = false;
        });
      } else {
        await _controller.setFlashMode(FlashMode.torch);
        setState(() {
          _isFlashOn = true;
        });
      }
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<List<String>?> getTextFromImage() async {
    try {
      // Ensure that the controller is initialized
      await _initializeControllerFuture;

      // Capture an image
      final image = await _controller.takePicture();
      //save image to storage and get path
      final path = image.path;
      //print(path);

      // Extract the text from the image
      String text = await FlutterTesseractOcr.extractText(image.path);
      final List<String> words = text.split(' ');
      return words;
    } catch (e) {
      //print('Error extracting text from image: $e');
      return [];
    }
  }

  Future<String> getExpDate() async {
    try {
      // Ensure that the controller is initialized
      await _initializeControllerFuture;

      // Capture an image
      final image = await _controller.takePicture();
      //save image to storage and get path
      final path = image.path;
      //print(path);

      // Extract the text from the image
      String text = await FlutterTesseractOcr.extractText(image.path);
      //print(text);
      String date = findBiggestDate(text);
      return date;
    } catch (e) {
      //print('Error extracting text from image: $e');
      return "Please scan again";
    }
  }

  String findBiggestDate(String text) {
    text = text.replaceAll(" ", "");
    // Regular expressions to match different date formats
    RegExp dateRegex = RegExp(
        r'\d{2}-\d{2}-\d{4}|\d{4}-\d{2}-\d{2}|\d{4}.\d{2}.\d{2}|\d{2}/\d{2}/\d{4}|\d{4}/\d{2}/\d{2}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (_isprocessing) {
                return const Center(
                    child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 10.0,
                    ),
                    SizedBox(width: 20.0),
                    Text('Processing...'),
                  ],
                ));
              } else if (snapshot.connectionState == ConnectionState.done) {
                // If the controller has been initialized, display the camera preview
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller),
                );
              } else if (snapshot.hasError) {
                // Handle errors during camera initialization
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Otherwise, display a loading indicator
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TransparentButton(
                  //   text: 'Ingredients',
                  //   selected: !_expirySelected, // or false, depending on your requirement
                  //   onPressed: () {
                  //     setState(() {
                  //       _expirySelected = false;
                  //     });
                  //   },
                  // ),
                  // ElevatedButton(
                  //   text: 'Expiry',
                  //   selected: _expirySelected, // or false, depending on your requirement
                  //   onPressed: () {
                  //     setState(() {
                  //       _expirySelected = true;
                  //     });
                  //   },
                  // )
                ],
              ))),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/toxic');
                    },
                    onTapDown: (_) {
                      setState(() {
                        _isSettingsButtonPressed = true;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _isSettingsButtonPressed = false;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _isSettingsButtonPressed = false;
                      });
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isSettingsButtonPressed
                              ? Colors.red
                              : Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  InkResponse(
                    onTap: () async {
                      setState(() {
                        _isprocessing = true;
                      });
                      // Round button on tap action
                      if (_expirySelected) {
                        String date = await getExpDate();
                        setState(() {
                          _isprocessing = false;
                        });
                        //say the date in voice
                        speak(date);
                      } else {
                        List<String> words =
                            await getTextFromImage().then((value) => value!);

                        //get user toxic array
                        String userId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';

                        try {
                          // Retrieve the document snapshot from Firestore
                          DocumentSnapshot snapshot = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .doc(userId)
                              .get();

                          // Retrieve the 'toxic' array from the document data
                          List<String> toxicArray =
                              (snapshot.data() as Map<String, dynamic>)['toxic']
                                  .cast<String>();

                          // Check if any of the words in the image are toxic

                          bool isToxic = false;
                          String toxicList = "";
                          for (String word in words) {
                            //print(word);

                            if (toxicArray.contains(word.toLowerCase())) {
                              toxicList += word + " ";
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
                                title:
                                    const Text('Allerginic Ingredients Found'),
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
                          _isprocessing = false;
                        });
                      }
                    },
                    onTapDown: (_) {
                      setState(() {
                        _isButtonPressed = true;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _isButtonPressed = false;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _isButtonPressed = false;
                      });
                    },
                    child: Container(
                      width: 90.0,
                      height: 90.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isButtonPressed ? Colors.red : Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 60.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  InkResponse(
                    onTap: () {
                      _toggleFlash();
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
