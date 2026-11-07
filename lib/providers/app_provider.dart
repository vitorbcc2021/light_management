import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/device.dart';
import '../services/mqtt_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final MqttService _mqtt = MqttService();
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  List<Device> devices = [];
  Map<String, String> brokerConfig = {
    'broker': 'test.mosquitto.org',
    'port': '1883',
    'username': '',
    'password': '',
  };

  AppMqttState get connectionState => _mqtt.connectionState;
  StreamSubscription? _msgSub;
  StreamSubscription? _connSub;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    devices = await _storage.loadDevices();
    brokerConfig = await _storage.loadBrokerConfig();
    notifyListeners();

    _connSub = _mqtt.connectionStream.listen((_) {
      notifyListeners();
    });

    _msgSub = _mqtt.messageStream.listen(_handleMessage);
  }

  Future<bool> connect() async {
    final clientId = 'tcc_${_uuid.v4().substring(0, 8)}';

    print(
      'Tentando conectar em: ${brokerConfig['broker']} na porta ${brokerConfig['port']}',
    );

    final success = await _mqtt.connect(
      broker: brokerConfig['broker']!,
      port: int.tryParse(brokerConfig['port'] ?? '1883') ?? 1883,
      username: brokerConfig['username'],
      password: brokerConfig['password'],
      clientId: clientId,
    );

    if (success) {
      print('Conectado com sucesso!');
      for (final d in devices) {
        _subscribeDevice(d);
      }
    } else {
      print('Falha na conexão: ${_mqtt.lastError}');
    }

    notifyListeners();
    return success;
  }

  void disconnect() {
    _mqtt.disconnect();
    for (final d in devices) {
      d.isOnline = false;
    }
    notifyListeners();
  }

  Future<void> saveBrokerConfig(Map<String, String> config) async {
    brokerConfig = config;
    await _storage.saveBrokerConfig(config);
    notifyListeners();
  }

  String? get connectionError => _mqtt.lastError;

  Future<void> addDevice(String name, String topic) async {
    final d = Device(id: _uuid.v4(), name: name, mqttTopic: topic);
    devices.add(d);
    _subscribeDevice(d);
    await _storage.saveDevices(devices);
    notifyListeners();
  }

  Future<void> removeDevice(String id) async {
    final d = devices.firstWhere((d) => d.id == id);
    _mqtt.unsubscribe(d.topicStatus);
    _mqtt.unsubscribe(d.topicTelemetry);
    devices.removeWhere((d) => d.id == id);
    await _storage.saveDevices(devices);
    notifyListeners();
  }

  Future<void> updateDeviceName(String id, String name) async {
    final d = devices.firstWhere((d) => d.id == id);
    d.name = name;
    await _storage.saveDevices(devices);
    notifyListeners();
  }

  void _subscribeDevice(Device d) {
    _mqtt.subscribe(d.topicStatus);
    _mqtt.subscribe(d.topicTelemetry);
  }

  void setBrightness(Device d, int value) {
    d.brightness = value;
    _mqtt.publishJson(d.topicCommand, {'cmd': 'brightness', 'value': value});
    notifyListeners();
  }

  void turnOn(Device d) {
    d.onTurnOn();
    _mqtt.publishJson(d.topicCommand, {'cmd': 'power', 'value': 'on'});
    notifyListeners();
  }

  Future<void> turnOff(Device d) async {
    d.onTurnOff();
    _mqtt.publishJson(d.topicCommand, {'cmd': 'power', 'value': 'off'});
    await _storage.saveDevices(devices);
    notifyListeners();
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final topic = msg['topic'] as String;
    final payload = msg['payload'] as String;
    for (final d in devices) {
      if (topic == d.topicStatus) {
        _handleStatus(d, payload);
      } else if (topic == d.topicTelemetry) {
        _handleTelemetry(d, payload);
      }
    }

    notifyListeners();
  }

  void _handleStatus(Device d, String payload) {
    try {
      final norm = payload.replaceAllMapped(
        RegExp(r'(-?\d+),(\d+)'),
        (m) => '${m[1]}.${m[2]}',
      );
      final data = jsonDecode(norm) as Map<String, dynamic>;
      d.isOnline = true;
      if (data['power'] == 'on' && !d.isOn) {
        d.onTurnOn();
      } else if (data['power'] == 'off' && d.isOn) {
        d.onTurnOff();
      }
      if (data['brightness'] != null) {
        d.brightness = (data['brightness'] as num).toInt();
      }
      if (data['temperature'] != null) {
        final temp = (data['temperature'] as num).toDouble();
        d.temperature = temp;
        if (d.isOn) {
          d.recordTelemetry(temp, d.brightness);
        }
      }
    } catch (_) {}
  }

  void _handleTelemetry(Device d, String payload) {
    try {
      final norm = payload.replaceAllMapped(
        RegExp(r'(-?\d+),(\d+)'),
        (m) => '${m[1]}.${m[2]}',
      );
      final data = jsonDecode(norm) as Map<String, dynamic>;
      d.isOnline = true;
      final temp = (data['temperature'] as num?)?.toDouble() ?? d.temperature;
      final bright = (data['brightness'] as num?)?.toInt() ?? d.brightness;
      d.recordTelemetry(temp, bright);
    } catch (_) {}
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _connSub?.cancel();
    _mqtt.dispose();
    super.dispose();
  }
}
