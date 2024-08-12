import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late final GenerativeModel _model;
  late final String apiKey;

  ApiService() {
    _initializeApiKey();
  }

  Future<void> _initializeApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('gemini_api_key') ?? 'GEMINI-API-KEY';

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<File> resizeImage(File file, int maxWidth, int maxHeight) async {
    final originalImage = img.decodeImage(await file.readAsBytes());
    final resizedImage = img.copyResize(originalImage!, width: maxWidth, height: maxHeight);
    final resizedFile = File(file.path)..writeAsBytesSync(img.encodeJpg(resizedImage));
    return resizedFile;
  }

  Future<String> describeImage(File imageFile) async {
    try {
      final resizedImage = await resizeImage(imageFile, 800, 800); // Resize to a max width/height of 800
      final imageBytes = await resizedImage.readAsBytes();

      final content = [
        Content.multi([
          TextPart("What is in this image?"),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        return 'Failed to describe image: No text response';
      }
    } catch (e) {
      return 'Error describing image: $e';
    }
  }
}
