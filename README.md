# ESP32 Smart Home Automation System

A cloud-connected Smart Home Automation and Safety System built using ESP32, Firebase Realtime Database, sensors, relays, and IoT technologies.

This project allows users to remotely monitor and control home appliances through Firebase while also supporting automatic control, scheduling, energy monitoring, and safety alerts.

---

# Features

- Remote appliance control using Firebase  
- Automatic sensor-based automation  
- Schedule-based appliance control  
- Real-time temperature monitoring  
- Motion-detection lighting system  
- Automatic water motor control  
- Smart curtain control using LDR  
- Fire detection alert system  
- Gas/smoke detection alert system  
- Buzzer warning system  
- Electricity usage tracking (kWh)  
- Monthly billing reset system  
- Device activity logs  
- Internet time synchronization using NTP  
- Object-Oriented Programming (OOP) architecture  

---

# Technologies Used

- ESP32
- Firebase Realtime Database
- Arduino IDE
- DHT11 Temperature Sensor
- PIR Motion Sensor
- MQ135 Gas Sensor
- LM393 Fire Sensor
- LDR Sensor
- Relay Module
- WiFi
- JSON Handling
- NTP Time Server

---

# Hardware Components

| Component | Quantity |
|---|---|
| ESP32 | 1 |
| DHT11 Sensor | 1 |
| PIR Motion Sensor | 1 |
| MQ135 Gas Sensor | 1 |
| LM393 Fire Sensor | 1 |
| LDR Sensor | 1 |
| Water Level Sensor | 1 |
| Relay Module | 4 |
| Buzzer | 1 |
| Jumper Wires | Multiple |
| Breadboard / PCB | 1 |

---

# System Architecture

```text
Sensors → ESP32 → Firebase → Mobile/Web App
              ↓
           Relays
              ↓
       Home Appliances
```

---

# Automation Logic

| Device | AUTO Mode Condition |
|---|---|
| Fan | Turns ON when temperature ≥ 20°C |
| Light | Turns ON when motion detected |
| Motor | Turns ON when water level is low |
| Curtain | Closes when room becomes dark |

---

# Firebase Features

The system uses Firebase Realtime Database for:

- Device state synchronization
- Remote control
- Scheduling
- Alert notifications
- Sensor data storage
- Energy usage tracking
- Device activity logging

---

# Energy Monitoring

The system calculates electricity consumption using:

```text
Energy (kWh) = Power (W) × Time (s) / 3600000
```

Features:
- Tracks usage of each appliance
- Calculates total consumption
- Generates warning alerts if limit exceeded
- Monthly automatic reset

---

# Safety Features

## Fire Detection
- Detects fire using LM393 fire sensor
- Activates buzzer
- Sends Firebase alert

## Gas/Smoke Detection
- Detects harmful gas/smoke using MQ135
- Triggers emergency warning
- Updates Firebase alert status

---

# Project Structure

```text
├── main.ino
├── FirebaseManager
├── SensorManager
├── Device Class
├── ModeController
├── BuzzerController
├── SafetyMonitor
├── UsageMonitor
└── BillingManager
```

---

# Pin Configuration

| Device | ESP32 Pin |
|---|---|
| Fan Relay | 23 |
| Light Relay | 22 |
| Motor Relay | 21 |
| Curtain Relay | 19 |
| Buzzer | 27 |
| PIR Sensor | 34 |
| Water Sensor | 35 |
| LDR Sensor | 32 |
| DHT11 | 4 |
| Fire Sensor | 25 |
| Gas Sensor | 26 |

---

# WiFi & Firebase Setup

Update these credentials inside the code:

```cpp
#define WIFI_SSID "Your_WiFi_Name"
#define WIFI_PASSWORD "Your_WiFi_Password"

#define FIREBASE_URL "Your_Firebase_URL"
#define FIREBASE_SECRET "Your_Firebase_Secret"
```

---

# How to Run

1. Install Arduino IDE
2. Install ESP32 Board Package
3. Install required libraries:
   - Firebase ESP Client
   - ArduinoJson
   - DHT Sensor Library
4. Connect ESP32
5. Upload the code
6. Open Serial Monitor
7. Connect Firebase database

---

# Future Improvements

- Mobile Application
- Voice Assistant Integration
- AI-based automation
- Camera surveillance
- MQTT support
- Energy analytics dashboard

---


# License

This project is for educational and learning purposes.
