import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nova/ui/home_view.dart';
import 'package:nova/ui/tutorial_screen.dart';
import 'package:nova/ui/settings_screen.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String defaultApiKey = 'GEMINI-API-KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  String apiKey = await getApiKey();
  Gemini.init(apiKey: apiKey);

  runApp(const MyApp());
}

Future<String> getApiKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('gemini_api_key') ?? defaultApiKey;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Navigation Tool',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeViewWithTutorial(),
    );
  }
}

class HomeViewWithTutorial extends StatefulWidget {
  const HomeViewWithTutorial({Key? key}) : super(key: key);

  @override
  _HomeViewWithTutorialState createState() => _HomeViewWithTutorialState();
}

class _HomeViewWithTutorialState extends State<HomeViewWithTutorial> {
  bool _showTutorial = false;

  void _toggleTutorial() {
    setState(() {
      _showTutorial = !_showTutorial;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/applogo.png',
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _toggleTutorial,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          const HomeView(),
          if (_showTutorial)
            Positioned.fill(
              child: TutorialScreen(onClose: _toggleTutorial),
            ),
        ],
      ),
    );
  }
}
