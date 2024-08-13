NOVA - Navigation and Orientation Visual Assistance

NOVA is an app designed to assist blind or visually impaired individuals in navigating their surroundings. It provides real-time object detection, text recognition, image description, and voice command features to help users better understand their environment.

Features
Object Detection: Detects objects in the user's surroundings in real-time.
Text Recognition: Recognizes and reads aloud text from the environment.
Image Description: Describes captured images using AI.
Voice Commands: Control the app hands-free by saying "Hey Nova."
Setup Instructions
Prerequisites
Flutter: Ensure you have Flutter installed. You can follow the official Flutter installation guide.
API Keys:
Google Gemini API Key: Required for image description features.
Picovoice API Key: Required for enabling voice command features using Picovoice's Porcupine and Rhino engines.
Step 1: Clone the Repository
Clone the repository to your local machine:


git clone https://github.com/ulookuglynoob/Nova-AI)
cd nova-app

Step 2: Set Up the Gemini API Key
Main.dart:

Open lib/main.dart.
Replace the placeholder API key with your Gemini API key.

ApiService.dart:
const String defaultApiKey = 'GEMINI-API-KEY';

Open lib/service/api_service.dart.
Ensure the API key is being passed correctly to the GenerativeModel in the ApiService constructor.

final String apiKey = 'GEMINI-API-KEY';

Step 3: Set Up the Picovoice API Key
PicovoiceUtil.dart:

Open lib/utils/picovoice_util.dart.
Replace the placeholder API key with your Picovoice API key.

const String picovoiceApiKey = 'PICOVOICE-API-KEY';

Step 4: Install Dependencies
Install all required dependencies by running the following command:


flutter pub get

Step 5: Run the App
Run the app on your preferred device or emulator:


flutter run
Contributing
If you want to contribute to this project, please fork the repository, make your changes, and submit a pull request. Contributions are welcome!

License
No license, the project is open source!

Contact
For any inquiries or support, please contact:

Email: ulookuglynoob@email.com

Please give us feedback. It really helps!
