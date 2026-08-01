class SessionRecord {
  final DateTime startTime;
  final DateTime endTime;
  final double minTemp;
  final double avgTemp;
  final double maxTemp;
  final int avgBrightness;

  SessionRecord({
    required this.startTime,
    required this.endTime,
    required this.minTemp,
    required this.avgTemp,
    required this.maxTemp,
    required this.avgBrightness,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'minTemp': minTemp,
    'avgTemp': avgTemp,
    'maxTemp': maxTemp,
    'avgBrightness': avgBrightness,
  };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    minTemp: (json['minTemp'] as num).toDouble(),
    avgTemp: (json['avgTemp'] as num).toDouble(),
    maxTemp: (json['maxTemp'] as num).toDouble(),
    avgBrightness: json['avgBrightness'] as int,
  );
}

class Device {
  final String id;
  String name;
  String mqttTopic;

  bool isOnline = false;
  bool isOn = false;
  int brightness = 100;
  double temperature = 0.0;

  DateTime? sessionStart;
  List<double> _sessionTemps = [];
  int _sessionBrightnessSum = 0;
  int _sessionBrightnessCount = 0;

  double? _lastSessionTemp;
  int? _lastSessionBrightness;

  List<SessionRecord> history = [];

  Device({required this.id, required this.name, required this.mqttTopic});

  String get topicCommand => '$mqttTopic/cmd';
  String get topicStatus => '$mqttTopic/status';
  String get topicTelemetry => '$mqttTopic/telemetry';

  void onTurnOn() {
    if (!isOn) {
      isOn = true;
      sessionStart = DateTime.now();
      _sessionTemps = [];
      _sessionBrightnessSum = 0;
      _sessionBrightnessCount = 0;
      _lastSessionTemp = temperature;
      _lastSessionBrightness = brightness;
    }
  }

  void onTurnOff() {
    if (isOn && sessionStart != null) {
      isOn = false;
      _finalizeSession();
    }
  }

  void recordTelemetry(double temp, int bright) {
    temperature = temp;
    if (isOn) {
      _sessionTemps.add(temp);
      _sessionBrightnessSum += bright;
      _sessionBrightnessCount++;
      _lastSessionTemp = temp;
      _lastSessionBrightness = bright;
    }
  }

  void _finalizeSession() {
    if (sessionStart == null || _sessionTemps.isEmpty) {
      if (_sessionTemps.isEmpty && sessionStart != null) {
        history.insert(
          0,
          SessionRecord(
            startTime: sessionStart!,
            endTime: DateTime.now(),
            minTemp: _lastSessionTemp ?? temperature,
            avgTemp: _lastSessionTemp ?? temperature,
            maxTemp: _lastSessionTemp ?? temperature,
            avgBrightness: _lastSessionBrightness ?? brightness,
          ),
        );
        if (history.length > 50) history = history.sublist(0, 50);
      }
      sessionStart = null;
      return;
    }

    final temps = _sessionTemps;
    temps.sort();
    final avg = _sessionBrightnessCount > 0
        ? (_sessionBrightnessSum / _sessionBrightnessCount).round()
        : (_lastSessionBrightness ?? brightness);

    history.insert(
      0,
      SessionRecord(
        startTime: sessionStart!,
        endTime: DateTime.now(),
        minTemp: temps.first,
        avgTemp: temps.reduce((a, b) => a + b) / temps.length,
        maxTemp: temps.last,
        avgBrightness: avg,
      ),
    );

    if (history.length > 50) history = history.sublist(0, 50);
    sessionStart = null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mqttTopic': mqttTopic,
    'history': history.map((s) => s.toJson()).toList(),
  };

  factory Device.fromJson(Map<String, dynamic> json) {
    final d = Device(
      id: json['id'],
      name: json['name'],
      mqttTopic: json['mqttTopic'],
    );
    if (json['history'] != null) {
      d.history = (json['history'] as List)
          .map((s) => SessionRecord.fromJson(s))
          .toList();
    }
    return d;
  }
}
