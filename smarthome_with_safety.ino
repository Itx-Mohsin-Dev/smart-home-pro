#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/RTDBHelper.h>
#include <ArduinoJson.h>
#include <time.h>
#include <DHT.h>
#include <WiFiClientSecure.h>

// ================================================
//  CONFIGURATION
// ================================================
#define WIFI_SSID           "S24 Ultra"
#define WIFI_PASSWORD       "devilbeast"
#define FIREBASE_URL        "https://smarthomefyp-3fcfd-default-rtdb.firebaseio.com/"
#define FIREBASE_SECRET     "2oFZvsdmlVOE7NJiUZajK8pkvdbS9pbcTHR4IK3U"

#define FAN_RELAY           23
#define LIGHT_RELAY         22
#define MOTOR_RELAY         21
#define CURTAIN_RELAY       19
#define BUZZER_PIN          27
#define PIR_PIN             34
#define WATER_PIN           35
#define LDR_PIN             32
#define DHT_PIN             4
#define DHTTYPE             DHT11

// ── NEW: Safety sensors ───────────────────────────
#define FIRE_PIN            25   // LM393 fire sensor  D0
#define GAS_PIN             26   // MQ135 gas sensor   D0

// ── Sensor thresholds ─────────────────────────────
#define LDR_LIGHT_THRESHOLD  1715
#define WATER_LOW_THRESHOLD  800

// ── Fan temperature ───────────────────────────────
#define FAN_ON_TEMP          20.0f

// ── PIR debounce ──────────────────────────────────
#define PIR_HOLD_LOOPS       5

// ── Timing ────────────────────────────────────────
#define LOOP_DELAY_MS       1000
#define SENSOR_PUSH_EVERY   10
#define USAGE_CHECK_EVERY   30
#define MAX_LOG_ENTRIES     20

const char* NTP_SERVER = "pool.ntp.org";
const char* TZ_STRING  = "PKT-5";

WiFiClientSecure client;

// ================================================
//  UTILITY: TIME HELPERS
// ================================================
int minutesFromString(const String& t) {
  return t.substring(0, 2).toInt() * 60 + t.substring(3, 5).toInt();
}

bool inScheduleRange(int now, int start, int end) {
  if (start <= end) return (now >= start && now <= end);
  return (now >= start || now <= end);
}

int getCurrentMinutes() {
  struct tm ti;
  if (!getLocalTime(&ti)) return -1;
  return ti.tm_hour * 60 + ti.tm_min;
}

String getTimestamp() {
  struct tm ti;
  if (!getLocalTime(&ti)) return "1970-01-01 00:00:00";
  char buf[20];
  strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", &ti);
  return String(buf);
}

// ================================================
//  CLASS: FirebaseManager
// ================================================
class FirebaseManager {
public:
  FirebaseManager() : _ready(false) {}

  void begin(const char* url, const char* secret) {
    _config.database_url = url;
    if (strlen(secret) > 0)
      _config.signer.tokens.legacy_token = secret;
    Firebase.begin(&_config, &_auth);
    Firebase.reconnectWiFi(true);
    _ready = true;
    Serial.println("[Firebase] Initialized");
  }

  bool isReady() { return _ready; }

  bool getJson(const String& path, DynamicJsonDocument& doc) {
    if (!isReady()) return false;
    if (Firebase.RTDB.getJSON(&_data, path.c_str())) {
      String raw = _data.jsonString();
      DeserializationError err = deserializeJson(doc, raw);
      if (err) { Serial.printf("[JSON ERR] %s\n", err.c_str()); return false; }
      return true;
    }
    Serial.printf("[GET ERR] %s\n", _data.errorReason().c_str());
    return false;
  }

  bool setString(const String& path, const String& value) {
    if (!isReady()) return false;
    bool ok = Firebase.RTDB.setString(&_data, path.c_str(), value.c_str());
    if (!ok) Serial.printf("[SET ERR] %s\n", _data.errorReason().c_str());
    return ok;
  }

  bool setBool(const String& path, bool value) {
    if (!isReady()) return false;
    bool ok = Firebase.RTDB.setBool(&_data, path.c_str(), value);
    if (!ok) Serial.printf("[SET ERR] %s\n", _data.errorReason().c_str());
    return ok;
  }

  bool setFloat(const String& path, float value) {
    if (!isReady()) return false;
    bool ok = Firebase.RTDB.setFloat(&_data, path.c_str(), value);
    if (!ok) Serial.printf("[SET ERR] %s\n", _data.errorReason().c_str());
    return ok;
  }

  bool getFloat(const String& path, float& out) {
    if (!isReady()) return false;
    if (Firebase.RTDB.getFloat(&_data, path.c_str())) {
      out = _data.to<float>(); return true;
    }
    return false;
  }

  void addFloat(const String& path, float delta) {
    float current = 0;
    getFloat(path, current);
    setFloat(path, current + delta);
  }

  // Rolling 20-log system
  void pushDeviceLog(const String& deviceId, const String& state, const String& mode) {
    String timestamp = getTimestamp();
    String safeKey   = timestamp;
    safeKey.replace(" ", "_");
    safeKey.replace(":", "-");
    String basePath = "/logs/devices/" + deviceId;

    int logCount = 0;
    if (Firebase.RTDB.getJSON(&_data, basePath.c_str())) {
      FirebaseJson* fJson = _data.to<FirebaseJson*>();
      size_t count = fJson->iteratorBegin();
      logCount = (int)count;
      fJson->iteratorEnd();
    }

    if (logCount >= MAX_LOG_ENTRIES) {
      if (Firebase.RTDB.getJSON(&_data, basePath.c_str())) {
        FirebaseJson* fJson = _data.to<FirebaseJson*>();
        String oldestKey = "";
        size_t count = fJson->iteratorBegin();
        for (size_t i = 0; i < count; i++) {
          int type = 0; String key, value;
          fJson->iteratorGet(i, type, key, value);
          if (oldestKey == "" || key < oldestKey) oldestKey = key;
        }
        fJson->iteratorEnd();
        if (oldestKey != "")
          Firebase.RTDB.deleteNode(&_data, (basePath + "/" + oldestKey).c_str());
      }
    }

    FirebaseJson logEntry;
    logEntry.set("state",     state);
    logEntry.set("mode",      mode);
    logEntry.set("timestamp", timestamp);
    Firebase.RTDB.setJSON(&_data, (basePath + "/" + safeKey).c_str(), &logEntry);
    Serial.printf("[LOG] %s -> %s (%s)\n", deviceId.c_str(), state.c_str(), mode.c_str());
  }

private:
  FirebaseData   _data;
  FirebaseConfig _config;
  FirebaseAuth   _auth;
  bool           _ready;
};

// ================================================
//  CLASS: SensorManager
// ================================================
class SensorManager {
public:
  SensorManager() : _dht(DHT_PIN, DHTTYPE), _filteredTemp(20.0f),
                    _ldrRaw(0), _waterRaw(0),
                    _motionRaw(0), _motionHoldCounter(0) {}

  void begin() {
    pinMode(PIR_PIN,  INPUT);
    _dht.begin();
  }

  void update() {
    // Temperature — EMA smoothed
    float raw = _dht.readTemperature();
    if (!isnan(raw)) _filteredTemp = (_filteredTemp * 0.7f) + (raw * 0.3f);

    // PIR with hold counter
    _motionRaw = digitalRead(PIR_PIN);
    if (_motionRaw == HIGH) {
      _motionHoldCounter = PIR_HOLD_LOOPS;
    } else if (_motionHoldCounter > 0) {
      _motionHoldCounter--;
    }

    _ldrRaw   = analogRead(LDR_PIN);
    _waterRaw = analogRead(WATER_PIN);

    Serial.printf("[Sensors] Temp=%.1f PIR_raw=%d PIR_held=%s LDR=%d Water=%d\n",
      _filteredTemp, _motionRaw,
      motionDetected() ? "YES" : "NO",
      _ldrRaw, _waterRaw);
  }

  float temperature()    const { return _filteredTemp; }
  bool  motionDetected() const { return (_motionRaw == HIGH) || (_motionHoldCounter > 0); }
  bool  isLight()        const { return _ldrRaw > LDR_LIGHT_THRESHOLD; }
  bool  isDark()         const { return !isLight(); }
  bool  waterLow()       const { return _waterRaw < WATER_LOW_THRESHOLD; }
  int   ldrRaw()         const { return _ldrRaw; }
  int   waterRaw()       const { return _waterRaw; }

private:
  DHT   _dht;
  float _filteredTemp;
  int   _ldrRaw;
  int   _waterRaw;
  int   _motionRaw;
  int   _motionHoldCounter;
};

// ================================================
//  CLASS: Device
// ================================================
class Device {
public:
  Device(const String& id, int relayPin, float wattage)
    : _id(id), _relayPin(relayPin), _wattage(wattage),
      _state(false), _prevState(false), _sessionStart(0) {}

  void begin() { pinMode(_relayPin, OUTPUT); applyRelay(false); }

  void setState(bool on) { _state = on; applyRelay(_state); }

  bool isOn()         const { return _state; }
  bool stateChanged() const { return _state != _prevState; }

  void trackEnergy(FirebaseManager& fb) {
    if (_state && !_prevState)  _sessionStart = millis();
    if (!_state && _prevState && _sessionStart > 0) {
      float seconds = (millis() - _sessionStart) / 1000.0f;
      float units   = (_wattage * seconds) / 3600000.0f;
      fb.addFloat("/usage/devices/" + _id, units);
      _sessionStart = 0;
    }
    _prevState = _state;
  }

  const String& id() const { return _id; }

private:
  void applyRelay(bool on) { digitalWrite(_relayPin, on ? LOW : HIGH); }

  String        _id;
  int           _relayPin;
  float         _wattage;
  bool          _state;
  bool          _prevState;
  unsigned long _sessionStart;
};

// ================================================
//  CLASS: ModeController
// ================================================
class ModeController {
public:
  static bool resolve(
    const String&        deviceId,
    const String&        mode,
    const JsonObject&    deviceNode,
    const JsonObject&    scheduleNode,
    const JsonObject&    settingsNode,
    const SensorManager& sensors,
    bool&                fanHysteresis
  ) {
    if (mode == "AUTO")     return resolveAuto(deviceId, sensors);
    if (mode == "SCHEDULE") return resolveSchedule(deviceId, scheduleNode);
    return resolveManual(deviceNode);
  }

private:
  static bool resolveManual(const JsonObject& node) {
    String s = node["state"] | "OFF";
    return s == "ON";
  }

  static bool resolveSchedule(const String& id, const JsonObject& sched) {
    int now = getCurrentMinutes();
    if (now < 0) return false;
    JsonObject entry = sched[id];
    if (entry.isNull()) return false;
    int s = minutesFromString(entry["start"] | "00:00");
    int e = minutesFromString(entry["end"]   | "00:00");
    return inScheduleRange(now, s, e);
  }

  static bool resolveAuto(const String& id, const SensorManager& sensors) {
    if (id == "fan1")     return sensors.temperature() >= FAN_ON_TEMP;
    if (id == "light1")   return sensors.motionDetected();
    if (id == "motor1")   return sensors.waterLow();
    if (id == "curtain1") return sensors.isDark();
    return false;
  }
};

// ================================================
//  CLASS: BuzzerController
// ================================================
class BuzzerController {
public:
  explicit BuzzerController(int pin) : _pin(pin) {}

  void begin() { pinMode(_pin, OUTPUT); digitalWrite(_pin, LOW); }

  // Called for peak-hour motor alert
  void update(const JsonObject& settings, bool motorOn) {
    // If safety alert is active, don't interfere — SafetyMonitor controls buzzer
    if (_safetyActive) return;

    int now = getCurrentMinutes();
    if (now < 0) { silence(); return; }
    int  ps   = minutesFromString(settings["peak_start"] | "18:00");
    int  pe   = minutesFromString(settings["peak_end"]   | "22:00");
    bool peak = inScheduleRange(now, ps, pe);
    digitalWrite(_pin, (peak && motorOn) ? HIGH : LOW);
  }

  // Called by SafetyMonitor to override buzzer
  void setSafetyAlert(bool active) {
    _safetyActive = active;
    if (active) {
      digitalWrite(_pin, HIGH);
    } else {
      digitalWrite(_pin, LOW);
    }
  }

  void silence() { digitalWrite(_pin, LOW); }

private:
  int  _pin;
  bool _safetyActive = false;
};

// ================================================
//  CLASS: SafetyMonitor
//  Monitors LM393 fire sensor and MQ135 gas sensor.
//  On detection: sounds buzzer, pushes alert to Firebase.
//  Clears alert automatically when danger is gone.
// ================================================
class SafetyMonitor {
public:
  SafetyMonitor() : _fireAlertActive(false), _gasAlertActive(false) {}

  void begin() {
    pinMode(FIRE_PIN, INPUT);
    pinMode(GAS_PIN,  INPUT);
  }

  void check(FirebaseManager& fb, BuzzerController& buzzer) {
    // Both sensors are active LOW (LOW = danger detected)
    bool fireDetected = (digitalRead(FIRE_PIN) == LOW);
    bool gasDetected  = (digitalRead(GAS_PIN)  == LOW);

    Serial.printf("[Safety] Fire=%s Gas=%s\n",
      fireDetected ? "DETECTED" : "OK",
      gasDetected  ? "DETECTED" : "OK");

    // ── Fire alert ────────────────────────────────
    if (fireDetected && !_fireAlertActive) {
      _fireAlertActive = true;
      fb.setBool("/alerts/fire/state",     true);
      fb.setString("/alerts/fire/message", "FIRE DETECTED! Check the room immediately.");
      fb.setString("/alerts/fire/timestamp", getTimestamp());
      Serial.println(">>> FIRE ALERT TRIGGERED <<<");
    } else if (!fireDetected && _fireAlertActive) {
      _fireAlertActive = false;
      fb.setBool("/alerts/fire/state",     false);
      fb.setString("/alerts/fire/message", "");
      Serial.println("[Safety] Fire cleared.");
    }

    // ── Gas alert ─────────────────────────────────
    if (gasDetected && !_gasAlertActive) {
      _gasAlertActive = true;
      fb.setBool("/alerts/gas/state",     true);
      fb.setString("/alerts/gas/message", "GAS/SMOKE DETECTED! Ventilate the room immediately.");
      fb.setString("/alerts/gas/timestamp", getTimestamp());
      Serial.println(">>> GAS ALERT TRIGGERED <<<");
    } else if (!gasDetected && _gasAlertActive) {
      _gasAlertActive = false;
      fb.setBool("/alerts/gas/state",     false);
      fb.setString("/alerts/gas/message", "");
      Serial.println("[Safety] Gas cleared.");
    }

    // ── Buzzer: sound if any danger active ────────
    buzzer.setSafetyAlert(fireDetected || gasDetected);
  }

  bool anyAlertActive() const { return _fireAlertActive || _gasAlertActive; }

private:
  bool _fireAlertActive;
  bool _gasAlertActive;
};

// ================================================
//  CLASS: UsageMonitor
// ================================================
class UsageMonitor {
public:
  UsageMonitor() : _warningActive(false) {}

  void check(FirebaseManager& fb) {
    float allowedUnits = 0.0f;
    fb.getFloat("/settings/allowed_units", allowedUnits);

    if (allowedUnits <= 0.0f) {
      if (_warningActive) {
        fb.setBool("/warning/state", false);
        fb.setString("/warning/message", "");
        _warningActive = false;
      }
      return;
    }

    const char* devices[] = { "fan1", "light1", "motor1", "curtain1" };
    float total = 0.0f;
    for (const char* d : devices) {
      float val = 0.0f;
      fb.getFloat(String("/usage/devices/") + d, val);
      total += val;
    }

    Serial.printf("[Usage] Total=%.4f Allowed=%.4f\n", total, allowedUnits);

    bool shouldWarn = (total >= allowedUnits);
    if (shouldWarn && !_warningActive) {
      String msg = "Warning: Usage (" + String(total, 4) +
                   " kWh) exceeded limit (" + String(allowedUnits, 4) + " kWh).";
      fb.setBool("/warning/state", true);
      fb.setString("/warning/message", msg);
      _warningActive = true;
    } else if (!shouldWarn && _warningActive) {
      fb.setBool("/warning/state", false);
      fb.setString("/warning/message", "");
      _warningActive = false;
    }
  }

private:
  bool _warningActive;
};

// ================================================
//  CLASS: BillingManager
// ================================================
class BillingManager {
public:
  void check(FirebaseManager& fb) {
    struct tm ti;
    if (!getLocalTime(&ti)) {
      Serial.println("[Billing] Time not ready — skipping reset check");
      return;
    }

    int todayMonth = ti.tm_mon + 1;
    int todayYear  = ti.tm_year + 1900;

    FirebaseData tempData;
    String lastReset = "";
    if (Firebase.RTDB.getString(&tempData, "/settings/last_reset")) {
      lastReset = tempData.stringData();
    }

    int lastYear  = lastReset.substring(0, 4).toInt();
    int lastMonth = lastReset.substring(5, 7).toInt();

    bool newMonth = (todayYear > lastYear) ||
                    (todayYear == lastYear && todayMonth > lastMonth);

    if (!newMonth) {
      Serial.printf("[Billing] Same month (%d-%02d) — no reset needed\n", todayYear, todayMonth);
      return;
    }

    Serial.println("[Billing] New month detected — resetting usage!");

    const char* devices[] = { "fan1", "light1", "motor1", "curtain1" };
    for (const char* d : devices) {
      fb.setFloat(String("/usage/devices/") + d, 0.0f);
    }

    fb.setFloat("/settings/allowed_units", 200.0f);
    fb.setBool("/warning/state", false);
    fb.setString("/warning/message", "");

    char dateStr[11];
    sprintf(dateStr, "%04d-%02d-01", todayYear, todayMonth);
    fb.setString("/settings/last_reset", String(dateStr));

    Serial.printf("[Billing] Reset complete. last_reset set to: %s\n", dateStr);
  }
};

// ================================================
//  GLOBALS
// ================================================
FirebaseManager  firebase;
SensorManager    sensors;
BuzzerController buzzer(BUZZER_PIN);
SafetyMonitor    safetyMonitor;
UsageMonitor     usageMonitor;
BillingManager   billingManager;

Device fan    ("fan1",     FAN_RELAY,     75.0f);
Device light  ("light1",   LIGHT_RELAY,   15.0f);
Device motor  ("motor1",   MOTOR_RELAY,  100.0f);
Device curtain("curtain1", CURTAIN_RELAY,  50.0f);

Device* allDevices[] = { &fan, &light, &motor, &curtain };
bool    fanHysteresis = false;
int     loopCount     = 0;

DynamicJsonDocument devicesDoc(2048);
DynamicJsonDocument settingsDoc(512);
DynamicJsonDocument scheduleDoc(512);

// ================================================
//  SETUP
// ================================================
void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.printf("[Heap] Free at start: %d bytes\n", ESP.getFreeHeap());

  fan.begin();
  light.begin();
  motor.begin();
  curtain.begin();
  buzzer.begin();
  sensors.begin();
  safetyMonitor.begin();  // ← NEW

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi Connected: " + WiFi.localIP().toString());

  configTime(0, 0, NTP_SERVER);
  setenv("TZ", TZ_STRING, 1);
  tzset();

  client.setInsecure();
  firebase.begin(FIREBASE_URL, FIREBASE_SECRET);
  delay(2000);
  Serial.println("[Firebase] Ready!");
  Serial.printf("[Heap] Free after init: %d bytes\n", ESP.getFreeHeap());

  billingManager.check(firebase);

  firebase.getJson("/devices",  devicesDoc);
  firebase.getJson("/settings", settingsDoc);
  firebase.getJson("/schedule", scheduleDoc);
}

// ================================================
//  LOOP
// ================================================
void loop() {
  loopCount++;

  // ── Safety check — runs every loop (highest priority) ──
  safetyMonitor.check(firebase, buzzer);  // ← NEW

  // Fetch Firebase every 2 loops (2 seconds)
  if (loopCount % 2 == 0) {
    devicesDoc.clear();
    settingsDoc.clear();
    scheduleDoc.clear();
    firebase.getJson("/devices",  devicesDoc);
    firebase.getJson("/settings", settingsDoc);
    firebase.getJson("/schedule", scheduleDoc);
  }

  JsonObject devicesNode  = devicesDoc.as<JsonObject>();
  JsonObject settingsNode = settingsDoc.as<JsonObject>();
  JsonObject scheduleNode = scheduleDoc.as<JsonObject>();

  sensors.update();

  for (Device* dev : allDevices) {
    JsonObject devNode = devicesNode[dev->id()];
    String mode = devNode["mode"] | "MANUAL";

    bool on = ModeController::resolve(
      dev->id(), mode,
      devNode, scheduleNode, settingsNode,
      sensors, fanHysteresis
    );

    dev->setState(on);

    if (dev->stateChanged()) {
      firebase.pushDeviceLog(dev->id(), on ? "ON" : "OFF", mode);
    }

    dev->trackEnergy(firebase);

    Serial.printf("[%s] mode=%s state=%s LDR=%d Water=%d\n",
      dev->id().c_str(), mode.c_str(), on ? "ON" : "OFF",
      sensors.ldrRaw(), sensors.waterRaw());
  }

  // Buzzer peak-hour logic (SafetyMonitor takes priority automatically)
  buzzer.update(settingsNode, motor.isOn());

  if (loopCount % SENSOR_PUSH_EVERY == 0) {
    firebase.setFloat("/sensors/temperature", sensors.temperature());
    Serial.println("[Temp pushed]");
  }

  if (loopCount % USAGE_CHECK_EVERY == 0) {
    usageMonitor.check(firebase);
  }

  Serial.printf("[Heap] Free: %d bytes\n", ESP.getFreeHeap());
  delay(LOOP_DELAY_MS);
}
