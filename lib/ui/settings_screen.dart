import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('gemini_api_key');
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
  }

  Future<void> _saveApiKey() async {
    String apiKey = _apiKeyController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Key saved successfully!')),
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
              'Enter your custom Gemini API Key for Image Description:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'API Key',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveApiKey,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
