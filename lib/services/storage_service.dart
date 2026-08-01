import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class StorageService {
  static const _devicesKey = 'LightManagement_devices';
  static const _brokerKey = 'LightManagement_broker_config';

  Future<List<Device>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_devicesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((j) => Device.fromJson(j)).toList();
  }

  Future<void> saveDevices(List<Device> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(devices.map((d) => d.toJson()).toList());
    await prefs.setString(_devicesKey, encoded);
  }

  Future<Map<String, String>> loadBrokerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_brokerKey);
    if (raw == null) {
      return {
        'broker': 'test.mosquitto.com',
        'port': '1883',
        'username': '',
        'password': '',
      };
    }
    return Map<String, String>.from(jsonDecode(raw));
  }

  Future<void> saveBrokerConfig(Map<String, String> config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_brokerKey, jsonEncode(config));
  }
}
