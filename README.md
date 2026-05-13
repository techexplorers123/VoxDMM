# VoxDMM

VoxDMM is a simple voice-enabled Bluetooth multimeter app built with Flutter.
It is designed to make supported digital multimeters easier to use for blind
and low-vision users by reading meter values and connection status aloud.

Current support is focused on Zotek Bluetooth multimeters.

## Features

- Connects to supported Bluetooth Low Energy multimeters.
- Decodes incoming meter readings and mode icons.
- Shows the current value, mode, and connection status.
- Announces readings and important status changes using text-to-speech.
- Handles reconnects and Android Bluetooth permissions.

## Requirements

- Flutter SDK with Dart `^3.11.5`
- Android Studio or Android SDK command-line tools
- An Android device with Bluetooth LE
- A supported Zotek Bluetooth multimeter

## Setup

Clone the project and install dependencies:

```sh
git clone https://github.com/techexplorers123/VoxDMM.git
cd VoxDMM
flutter pub get
```

Check that Flutter can see your Android device:

```sh
flutter devices
```

Run the app in debug mode:

```sh
flutter run
```

## Build

Build a debug APK:

```sh
flutter build apk --debug
```

Build a release APK:

```sh
flutter build apk --release
```

The APK output is usually written to:

```text
build/app/outputs/flutter-apk/
```

## Development

Run static analysis:

```sh
flutter analyze
```

Run tests:

```sh
flutter test
```

Format Dart files:

```sh
dart format lib test
```

Regenerate the Android app name or launcher icons after changing the related
configuration in `pubspec.yaml`:

```sh
dart run names_launcher:change
dart run flutter_launcher_icons
```

## Permissions

The Android app requests Bluetooth permissions needed for scanning and
connecting to BLE devices. On older Android versions, location permissions may
also be required by the platform for Bluetooth scanning.

## License

VoxDMM is released under the GNU Affero General Public License v3.0. See
`LICENSE` for details.
