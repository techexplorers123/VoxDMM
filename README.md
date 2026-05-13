# VoxDMM

VoxDMM is a simple voice-enabled Bluetooth multimeter app built with Flutter.
It is designed to make supported digital multimeters easier to use for blind
and low-vision users by reading meter values and connection status aloud.

Current support is only for Zotek Bluetooth multimeters, but more models may
be added in the future.

## Features

- Connects to supported Bluetooth Low Energy multimeters
- Decodes incoming meter readings and mode icons
- Shows the current value, mode, and connection status
- Announces readings and important status changes using text-to-speech
- Accessibility-focused interface for blind and low-vision users

## supported models

| Aneng  | BSIDE    | ZOYI     | Status                                           |
| ------ | -------- | -------- | ------------------------------------------------ |
| 9002   | ZT-300AB | ZT-300AB | Yes                                              |
| V05B   | ZT-5B    | ZT-5B    | Should work, submit a PR if any fixes are needed |
| ST207  | ZT-5BQ   | ZT-5BQ   | Should work, submit a PR if any fixes are needed |
| AN999S | -        | ZT-5566S | Not completely tested                            |

## Download

Prebuilt APK files are available from the GitHub Releases page:

[VoxDMM Releases](https://github.com/techexplorers123/VoxDMM/releases)

Download the latest release APK and install it on your Android device.
coming to playstore later

## Build

### Requirements

- Flutter SDK with Dart
- Android Studio or Android SDK command-line tools
- An Android device with Bluetooth LE support
- A supported Zotek Bluetooth multimeter

### Setup

Install flutter and setup flutter for android development if not already done:
see [getting started with flutter](https://docs.flutter.dev/install/quick) and [setup android development](https://docs.flutter.dev/platform-integration/android/setup) for more info.

Clone the project and install dependencies:

```sh
git clone https://github.com/techexplorers123/VoxDMM.git
cd VoxDMM
flutter pub get
```

### Run

Run the app in debug mode:

```sh
flutter run
```

### APK Build

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

### Launcher Icons and App Name

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

## Contributing

Contributions are welcome.

You can help by:

- Adding support for more Bluetooth multimeters
- Improving accessibility and speech feedback
- Fixing bugs and improving stability
- Improving the UI and usability
- Writing documentation or examples

To contribute:

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Commit and push your work
5. Open a pull request

Please keep code readable and test changes before submitting.

## License

VoxDMM is released under the GNU Affero General Public License v3.0. See
`LICENSE` for details.
