# TODO

## Near Term

- Add a clear supported-device list with tested model names.
- Improve error messages when Bluetooth, permissions, or device discovery fail.
- Add basic widget and service tests for meter decoding and speech behavior.
- Add screenshots or a short demo video to the README.
- Document how to capture sample BLE data for new meter support.

## Later

- Support more Bluetooth multimeter models.
- Add user settings for speech rate, volume, and announcement frequency.
- Add a manual reconnect button.
- Add reading history with simple export.
- Improve accessibility labels and screen reader navigation.

## Release Checklist

- Run `dart format lib test`.
- Run `flutter analyze`.
- Run `flutter test`.
- Test on a real Android device with a supported meter.
- Build the release APK with `flutter build apk --release`.
