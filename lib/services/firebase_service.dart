import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference database = FirebaseDatabase.instance.ref();
  
  // Listen to real-time changes on "devices" node
  static Stream<DatabaseEvent> listenToAllDevices() {
    return database.child('devices').onValue;
  }
  
  // Update device state (ON/OFF)
  static Future<void> setDeviceState(String deviceId, String state) async {
    await database.child('devices/$deviceId/state').set(state);
  }
  
  // Get single device data
  static Future<DatabaseEvent> getDevice(String deviceId) async {
    return await database.child('devices/$deviceId').once();
  }
}