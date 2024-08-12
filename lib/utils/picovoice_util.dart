import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:rhino_flutter/rhino_manager.dart';

class PicovoiceUtil {
  final FlutterTts flutterTts;
  final Function stopAll;
  final Function toggleObjectDetection;
  final Function toggleTextRecognition;
  final Function toggleImageDescription;
  late PorcupineManager _porcupineManager;
  late RhinoManager _rhinoManager;
  bool isListeningForCommand = false;

  PicovoiceUtil(this.flutterTts, this.stopAll, this.toggleObjectDetection,
      this.toggleTextRecognition, this.toggleImageDescription);

  Future<void> initPicovoice() async {
  try {
    _porcupineManager = await PorcupineManager.fromKeywordPaths(
      "PICOVOICE-API-KEY",
      ["assets/models/Hey-Nova_en_android_v3_0_0.ppn"],
      (int keywordIndex) async {
        if (keywordIndex == 0) {
          await stopAll();
          await flutterTts.speak("Yes?");
          isListeningForCommand = true;
          await _startRhinoListening();
        }
      },
    );

    _rhinoManager = await RhinoManager.create(
      "6yhnDSr6v3F6skMY93vu1lbowi60h7GrkaS5wbkaDrTNR5jllPfqFA==",
      "assets/models/Nova_en_android_v3_0_0.rhn",
      (inference) async {
        if (isListeningForCommand) {
          if (inference.isUnderstood ?? false) {
            if (inference.intent == "objectDetection") {
              await flutterTts.speak("Toggling object detection.");
              toggleObjectDetection();
            } else if (inference.intent == "textDetection") {
              await flutterTts.speak("Toggling text detection.");
              toggleTextRecognition();
            } else if (inference.intent == "imageDescription") {
              await flutterTts.speak("Toggling image description.");
              toggleImageDescription();
            }
          } else {
            await flutterTts.speak("Sorry, I didn't understand that.");
          }
          isListeningForCommand = false;
        }
      },
    );

    await _porcupineManager.start();
  } catch (e) {
    // Handle specific errors related to microphone initialization or other issues
    toggleObjectDetection();
    print('Error initializing Picovoice: $e');
    await flutterTts.speak("An error occurred while initializing the microphone.");
  }
}


  Future<void> _startRhinoListening() async {
    await _rhinoManager.process();
    print("Rhino listening for commands");
  }

  Future<void> dispose() async {
    await _porcupineManager.stop();
  }

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }
}
