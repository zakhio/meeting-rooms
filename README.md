# How to find a free meeting room?

After COVID-19 people are going back to the offices, so do the old problem to find a free meeting
room. This is a simple app that trys to address it by providing an overview over free and busy 
meeting rooms available in Google Calendar.

One can try it on https://meeting-rooms.zakh.io. It is available only for testers, so drop me a
message to andrey@zakh.io.

## Building

This is a Flutter application for Web, so you need to have Flutter SDK installed on your machine
(more here: [Install instructions][flutter-sdk-install])

This application is using [OAuth 2.0 to Access Google APIs][docs-oauth-to-access-google-apis].
Necessary setup actions:

1. Create new OAuth 2.0 Client in https://console.cloud.google.com/apis/credentials
    * Add `http://localhost:3000` for Authorized JavaScript origins and Authorized redirect URIs
2. Create Consent App here https://console.cloud.google.com/apis/credentials/consent

Then run the app

```shell
flutter run web --web-port=3000 --dart-define=OAUTH_CLIENT_ID=${OAUTH_CLIENT_ID} --target lib/main_production.dart
```

[flutter-sdk-install]: https://docs.flutter.dev/get-started/install

[docs-oauth-to-access-google-apis]: https://developers.google.com/identity/protocols/oauth2