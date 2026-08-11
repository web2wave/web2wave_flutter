# Publishing Web2Wave Flutter Package to pub.dev

## Version 1.1.10 Changes

- Send `device_model` header for identify fingerprinting (Android `Build.MODEL`, iOS machine id)
- Improves web ↔ mobile matching when `screen_size` differs

## Steps to Publish

```bash
cd /Users/igorlyubimov/web2wave/web2wave_flutter
flutter analyze
flutter pub publish --dry-run
flutter pub publish
```
