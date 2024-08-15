import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _geminiApiKeyController = TextEditingController();
  final TextEditingController _picovoiceApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? geminiApiKey = prefs.getString('gemini_api_key');
    String? picovoiceApiKey = prefs.getString('picovoice_api_key');
    if (geminiApiKey != null) {
      _geminiApiKeyController.text = geminiApiKey;
    }
    if (picovoiceApiKey != null) {
      _picovoiceApiKeyController.text = picovoiceApiKey;
    }
  }

  Future<void> _saveApiKeys() async {
    String geminiApiKey = _geminiApiKeyController.text;
    String picovoiceApiKey = _picovoiceApiKeyController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', geminiApiKey);
    await prefs.setString('picovoice_api_key', picovoiceApiKey);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Keys saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions to obtain API Keys:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. To obtain your Gemini API Key for Image Description, go to the Google API page and follow the instructions to create and retrieve your key.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '2. To obtain your Picovoice API Key for voice commands, go to the Picovoice API page and follow the instructions to create and retrieve your key.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter your custom Gemini API Key:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _geminiApiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Gemini API Key',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter your custom Picovoice API Key:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _picovoiceApiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Picovoice API Key',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveApiKeys,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
