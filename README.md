<img src="./assets/images/applogo.png" alt="Nova" width="300">

# NOVA - Navigation and Orientation Visual Assistance

**NOVA** is an app designed to assist blind or visually impaired individuals in navigating their surroundings. It provides several key features:

1. **Object Detection**: NOVA detects objects in the user's surroundings in real-time.
2. **Text Recognition**: The app recognizes and reads aloud text from the environment.
3. **Image Description**: NOVA describes captured images using AI.
4. **Voice Commands**: Users can control the app hands-free by saying "Hey Nova."

## Setup Instructions

### Prerequisites

Make sure you have Flutter installed. You can follow the official Flutter installation guide.

### API Keys

You'll need the following API keys:

1. **Google Gemini API Key**: Required for image description features.
2. **Picovoice API Key**: Needed to enable voice command features using Picovoice's Porcupine and Rhino engines.

### Step 1: Clone the Repository

Clone the repository to your local machine:

1. Run the following command in your terminal:

```bash
git clone https://github.com/ulookuglynoob/Nova-AI cd nova-app
```

### Step 2: Set Up the Gemini API Key

1. Open `lib/main.dart`.
2. Replace the placeholder API key 'YOUR-GEMINI-API-KEY' with your Gemini API key.

Example (in `lib/main.dart`):

```dart
apiKey = prefs.getString('gemini_api_key') ?? 'YOUR-GEMINI-API-KEY';
```

### Step 3: Set Up the Picovoice API Key

1. Open `lib/utils/picovoice_util.dart`.
2. Replace the placeholder API key 'YOUR-PICOVOICE-API-KEY' with your Picovoice API key.

Example (in `lib/utils/picovoice_util.dart`):

```dart
String apiKey = prefs.getString('picovoice_api_key') ?? 'YOUR-PICOVOICE-API-KEY';
```

### Step 4: Install Dependencies

Install all required dependencies by running the following command:

```bash
flutter pub get
```

### Step 5: Run the App

Run the app on your preferred device:

```bash
flutter run
```


## License

No license – the project is open source!

## Contact

For any inquiries or support, please contact:

Email: ulookuglynoob@email.com

Please give us feedback. It really helps!
