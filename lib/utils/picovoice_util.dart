import 'package:flutter_tts/flutter_tts.dart';
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

  PicovoiceUtil(this.flutterTts, this.stopAll, this.toggleObjectDetection, this.toggleTextRecognition, this.toggleImageDescription);

  Future<void> initPicovoice() async {
    _porcupineManager = await PorcupineManager.fromKeywordPaths(
      "6yhnDSr6v3F6skMY93vu1lbowi60h7GrkaS5wbkaDrTNR5jllPfqFA==",
      ["assets/models/Hey-Nova_en_android_v3_0_0.ppn"],
      (int keywordIndex) async {
        if (keywordIndex == 0) {
          await stopAll();  // Stop all activities when the wake word is detected
          await flutterTts.speak("Yes?");
          isListeningForCommand = true;  // Indicate that we're now listening for a command
          print("Wake word detected");
          await _startRhinoListening();  // Start Rhino listening for commands
        }
      },
    );

    _rhinoManager = await RhinoManager.create(
      "6yhnDSr6v3F6skMY93vu1lbowi60h7GrkaS5wbkaDrTNR5jllPfqFA==",
      "assets/models/Nova_en_android_v3_0_0.rhn",
      (inference) async {
        if (isListeningForCommand) {
          print("Rhino inference received: $inference");
          if (inference.isUnderstood ?? false) {
            print("Intent understood: ${inference.intent}");
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
            print("Intent not understood.");
          }
          isListeningForCommand = false;  // Reset listening for command flag
        }
      },
    );

    await _porcupineManager.start();
    print("Porcupine manager started");
  }

  Future<void> _startRhinoListening() async {
    await _rhinoManager.process();  // Start processing Rhino commands
    print("Rhino listening for commands");
  }

  Future<void> dispose() async {
    await _porcupineManager.stop();
    // No need to stop _rhinoManager as it does not have start/stop methods
  }
}
