class Device {
  final String id;
  final String name;
  final String type;
  final bool isOn;
  final String status;
  final double powerConsumption;
  final String location;
  final DateTime lastUpdated;
  final Map<String, dynamic> settings;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.status,
    required this.powerConsumption,
    required this.location,
    required this.lastUpdated,
    required this.settings,
  });

  // Factory constructor for sample data
  factory Device.fan() {
    return Device(
      id: 'fan_001',
      name: 'Living Room Fan',
      type: 'fan',
      isOn: true,
      status: 'Auto Mode',
      powerConsumption: 75.5,
      location: 'Living Room',
      lastUpdated: DateTime.now(),
      settings: {
        'temperature_threshold': 26.0,
        'speed': 3,
        'mode': 'auto',
        'schedule': '9:00 AM - 11:00 PM',
      },
    );
  }

  factory Device.bulb() {
    return Device(
      id: 'bulb_001',
      name: 'Living Room Lights',
      type: 'bulb',
      isOn: true,
      status: 'Motion Detected',
      powerConsumption: 45.2,
      location: 'Living Room',
      lastUpdated: DateTime.now(),
      settings: {
        'brightness': 80,
        'color_temp': 'warm',
        'motion_timeout': 5,
        'schedule': '6:00 PM - 11:00 PM',
      },
    );
  }

  factory Device.curtains() {
    return Device(
      id: 'curtains_001',
      name: 'Main Curtains',
      type: 'curtains',
      isOn: false,
      status: 'Closed',
      powerConsumption: 12.3,
      location: 'Living Room',
      lastUpdated: DateTime.now(),
      settings: {
        'light_threshold': 300,
        'auto_mode': true,
        'position': 0,
        'schedule': 'Sunrise - Sunset',
      },
    );
  }

  factory Device.waterMotor() {
    return Device(
      id: 'water_motor_001',
      name: 'Water Motor',
      type: 'water_motor',
      isOn: true,
      status: 'Tank: 75%',
      powerConsumption: 850.0,
      location: 'Terrace',
      lastUpdated: DateTime.now(),
      settings: {
        'tank_level': 75,
        'threshold': 95,
        'schedule_time': '9:00 AM',
        'auto_off': true,
      },
    );
  }
}