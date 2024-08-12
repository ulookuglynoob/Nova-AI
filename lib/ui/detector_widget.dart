import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nova/text_recognition_tts.dart';
import 'package:nova/models/recognition.dart';
import 'package:nova/models/screen_params.dart';
import 'package:nova/service/detector_service.dart';
import 'package:nova/ui/box_widget.dart';
import 'package:nova/service/api_service.dart';
import 'package:nova/utils/picovoice_util.dart';

class DetectorWidget extends StatefulWidget {
  const DetectorWidget({Key? key}) : super(key: key);

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget> with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  CameraController? _cameraController;
  get _controller => _cameraController;
  Detector? _detector;
  StreamSubscription? _subscription;
  List<Recognition>? results;
  Map<String, String>? stats;
  final FlutterTts flutterTts = FlutterTts();
  final TextRecognitionTTS textRecognitionTTS = TextRecognitionTTS();
  final ApiService apiService = ApiService();
  bool isDetecting = true;
  bool isSpeaking = false;
  bool isPaused = false;
  bool isTextRecognitionRunning = false;
  bool isImageDescriptionRunning = false;

  late PicovoiceUtil picovoiceUtil;

  final double _fixedExposureOffset = 1.0; 

  void _stopAll() async {
    print('Stopping all activities');
    await flutterTts.stop();
    setState(() {
      isDetecting = false;
      isPaused = true;
      isTextRecognitionRunning = false;
      isImageDescriptionRunning = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
    picovoiceUtil = PicovoiceUtil(flutterTts, _stopAll, _toggleObjectDetection, _toggleTextRecognition, _toggleImageDescription);
    picovoiceUtil.initPicovoice();
  }


  void _initStateAsync() async {
    print('Initializing camera...');
    await _initializeCamera();
    print('Camera initialized');
    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        _subscription = instance.resultsStream.stream.listen((values) {
          if (isDetecting && !isPaused && !isTextRecognitionRunning && !isImageDescriptionRunning) {
            setState(() {
              results = values['recognitions'];
              stats = values['stats'];
            });
            _processDetections();
          }
        });
        print('Detector started and listening to results stream');
      });
    }).catchError((error) {
      print('Error initializing detector: $error');
    });
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      )..initialize().then((_) async {
          await _controller.startImageStream(onLatestImageAvailable);
          setState(() {
            ScreenParams.previewSize = _controller.value.previewSize!;
            ScreenParams.screenPreviewSize = MediaQuery.of(context).size;
          });
          print('Camera streaming started');

          // Set fixed exposure offset
          await _controller.setExposureOffset(_fixedExposureOffset);

          // Optionally set a specific exposure mode
          await _controller.setExposureMode(ExposureMode.auto);
        });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
  if (_cameraController == null || !_controller.value.isInitialized) {
    print('Camera controller not initialized');
    return const SizedBox.shrink();
  }

  var screenSize = MediaQuery.of(context).size;
  var previewSize = _controller.value.previewSize!;
  var screenAspectRatio = screenSize.width / screenSize.height;
  var previewAspectRatio = previewSize.height / previewSize.width;

  return Scaffold(
    body: Stack(
      children: [
        OverflowBox(
          maxHeight: screenAspectRatio > previewAspectRatio
              ? screenSize.height
              : screenSize.width / previewAspectRatio,
          maxWidth: screenAspectRatio > previewAspectRatio
              ? screenSize.height * previewAspectRatio
              : screenSize.width,
          child: CameraPreview(_controller),
        ),
        _boundingBoxes(),
        Positioned.fill(
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _toggleObjectDetection,
                    icon: Icon(
                      isPaused ? Icons.visibility : Icons.pause,
                      color: Colors.white,
                    ),
                    tooltip: isPaused ? 'Resume Object Detection' : 'Pause Object Detection',
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _toggleTextRecognition,
                    icon: Icon(
                      isTextRecognitionRunning ? Icons.stop : Icons.text_fields,
                      color: Colors.white,
                    ),
                    tooltip: isTextRecognitionRunning ? 'Stop Text Detection' : 'Start Text Detection',
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: _toggleImageDescription,
                    icon: Icon(
                      isImageDescriptionRunning ? Icons.stop : Icons.image,
                      color: Colors.white,
                    ),
                    tooltip: isImageDescriptionRunning ? 'Stop Image Description' : 'Start Image Description',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Future<void> _pauseDetection() async {
    print('Pausing detection');
    await flutterTts.stop();
    setState(() {
      isDetecting = false;
    });
  }

  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: results!.map((box) => BoxWidget(result: box)).toList(),
    );
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    print('New image available');
    _detector?.processFrame(cameraImage);
  }

  String _getPosition(double left, double right) {
    double screenWidth = ScreenParams.screenPreviewSize.width;
    double objectMidPoint = (left + right) / 2;

    if (objectMidPoint < screenWidth * 0.4) {
      return "on the left";
    } else if (objectMidPoint > screenWidth * 0.6) {
      return "on the right";
    } else {
      return "in front";
    }
  }

  void _processDetections() async {
    if (results == null || results!.isEmpty || isSpeaking) return;

    StringBuffer sb = StringBuffer();
    for (var result in results!) {
      String position = _getPosition(result.renderLocation.left, result.renderLocation.right);
      sb.write("${result.label} detected $position. ");
    }

    isSpeaking = true;
    await flutterTts.speak(sb.toString());
    isSpeaking = false;

    setState(() {
      isDetecting = false;
    });
    await Future.delayed(const Duration(seconds: 5));
    if (!isPaused && !isTextRecognitionRunning && !isImageDescriptionRunning) {
      setState(() {
        isDetecting = true;
      });
    }
  }

  void _toggleObjectDetection() async {
    if (isTextRecognitionRunning || isImageDescriptionRunning) return;

    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      await _pauseDetection();
      await flutterTts.speak("Object detection paused");
    } else {
      await flutterTts.speak("Object detection resuming");
      await Future.delayed(const Duration(seconds: 1)); // 1-second delay
      setState(() {
        isDetecting = true;
      });
    }
  }

  void _toggleTextRecognition() async {
    if (isTextRecognitionRunning) {
      setState(() {
        isTextRecognitionRunning = false;
        isDetecting = !isPaused; // Resume object detection if not paused
      });
      return;
    }

    setState(() {
      isTextRecognitionRunning = true;
      isDetecting = false;
    });

    await flutterTts.speak('Text detection starting');
    _subscription?.pause();

    // Capture an image and recognize text
    String? recognizedText = await textRecognitionTTS.recognizeText(_cameraController!);
    if (recognizedText != null) {
      await flutterTts.speak("The text is: $recognizedText");
    } else {
      await flutterTts.speak("No text recognized");
    }

    setState(() {
      isTextRecognitionRunning = false;
      isDetecting = !isPaused; // Resume object detection if not paused
    });
    _subscription?.resume();
  }

  void _toggleImageDescription() async {
  if (isImageDescriptionRunning) {
    setState(() {
      isImageDescriptionRunning = false;
      isDetecting = !isPaused; // Resume object detection if not paused
    });
    return;
  }

  setState(() {
    isImageDescriptionRunning = true;
    isDetecting = false;
  });

  await flutterTts.speak('Image description starting');
  _subscription?.pause();

  // Capture an image and send to API for description
  try {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/temp_image.jpg';
    final XFile imageFile = await _cameraController!.takePicture();

    // Move the image file to the desired location
    await File(imageFile.path).copy(imagePath);

    final description = await apiService.describeImage(File(imagePath));
    await flutterTts.speak(description);
  } catch (e) {
    print('Error describing the image: $e');
    await flutterTts.speak('Error describing the image');
  }

  setState(() {
    isImageDescriptionRunning = false;
    isDetecting = !isPaused; // Resume object detection if not paused
  });
  _subscription?.resume();
}


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        print('App is inactive');
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        print('App is resumed');
        _initStateAsync();
        break;
      default:
    }
  }


  @override
  void dispose() {
    print('Disposing resources');
    WidgetsBinding.instance.removeObserver(this);
    picovoiceUtil.dispose();
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    textRecognitionTTS.dispose();
    super.dispose();
  }
}
