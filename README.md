# qr_scanner

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# QR_scanner" 

This Flutter app allows users to scan QR codes and barcodes using their device's camera, and also provides functionality to select and scan QR codes from the gallery. Scanned data is stored in Firebase Firestore, and users can view their scan history.

Features
Scan QR codes and barcodes using the device's camera.
Select QR codes from the gallery for scanning.
Save scan history to Firebase Firestore.
View scan history in descending order.
Prerequisites
Flutter SDK installed.
Firebase project set up with Firestore enabled.
An Android/iOS emulator or a physical device for testing.
Installation
Clone the Repository:
git clone https://github.com/nayankeote-2204/QR_scanner.git
cd QR_scanner
Install Dependencies:
flutter pub get
Configure Firebase:

Go to the Firebase Console.
Create a new project or use an existing one.
Add Firebase to your Flutter app by following the official instructions.
Download the google-services.json (for Android) or GoogleService-Info.plist (for iOS) from the Firebase Console.
Place the google-services.json file in the android/app directory.
Place the GoogleService-Info.plist file in the ios/Runner directory.
Update Firebase Configuration for Your App:

For Android, ensure you have the google-services plugin in your android/build.gradle:
classpath 'com.google.gms:google-services:4.3.14'
And apply the plugin in android/app/build.gradle:
apply plugin: 'com.google.gms.google-services'
For iOS, ensure you have the necessary configurations in ios/Podfile. Make sure platform :ios, '10.0' or later is set.

Run the App:
flutter run
Usage
Scanning QR Codes and Barcodes:

Open the app.
Point the camera at a QR code or barcode.
The app will vibrate and process the scanned data.
If the QR code is valid, it will open the link in an external application (e.g., a web browser).

Viewing Scan History:
Tap the "History" icon in the AppBar to view the list of previously scanned QR codes and barcodes.
