import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  final VoidCallback onClose;

  const TutorialScreen({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'How to Use the App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Object Detection'),
                  subtitle: Text('Detect objects in your surroundings in real-time.'),
                ),
                const ListTile(
                  leading: Icon(Icons.text_fields),
                  title: Text('Text Detection'),
                  subtitle: Text('Recognize and read aloud text from the environment.'),
                ),
                const ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Image Description'),
                  subtitle: Text('Describe captured images using AI.'),
                ),
                const ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Voice Commands'),
                  subtitle: Text('Control the app hands-free by saying "Hey Nova."'),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'About Us',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'NOVA, which stands for Navigation and Orientation Visual Assistance, '
                    'is designed to help blind or visually impaired individuals '
                    'navigate their environment more effectively.'
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
