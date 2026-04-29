// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, kIsWeb;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'smarthomefyp',
    authDomain: 'smarthomefyp.firebaseapp.com',
    databaseURL: 'https://smarthomefyp-default-rtdb.firebaseio.com',
    storageBucket: 'smarthomefyp.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD76YVR0ubOxGNU9__GhnJGkTzWXH5Br-8',
    appId: '1:726046775569:android:7187f493c3cdc9e39f94b0',
    messagingSenderId: '726046775569',
    projectId: 'smarthomefyp',
    databaseURL: 'https://smarthomefyp-default-rtdb.firebaseio.com',
    storageBucket: 'smarthomefyp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'smarthomefyp',
    databaseURL: 'https://smarthomefyp-default-rtdb.firebaseio.com',
    storageBucket: 'smarthomefyp.appspot.com',
  );
}