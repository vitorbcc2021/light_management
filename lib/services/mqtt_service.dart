import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum AppMqttState { disconnected, connecting, connected, error }

class MqttService {
  MqttServerClient? _client;

  AppMqttState connectionState = AppMqttState.disconnected;
  String? lastError;

  final _connectionStateController = StreamController<AppMqttState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<AppMqttState> get connectionStream =>
      _connectionStateController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<bool> connect({
    required String broker,
    required int port,
    String? username,
    String? password,
    required String clientId,
  }) async {
    _setState(AppMqttState.connecting);

    _client = MqttServerClient.withPort(broker, clientId, port);
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 30;
    _client!.connectTimeoutPeriod = 30000;
    _client!.autoReconnect = true;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onAutoReconnected = _onReconnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillQos(MqttQos.atLeastOnce)
        .startClean();

    if (username != null && username.isNotEmpty) {
      connMsg.authenticateAs(username, password ?? '');
    }

    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect();
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _listenMessages();
        return true;
      } else {
        lastError = 'Estado: ${_client!.connectionStatus!.state}';
        _setState(AppMqttState.error);
        return false;
      }
    } catch (e) {
      lastError = e.toString();
      _setState(AppMqttState.error);
      return false;
    }
  }

  void _listenMessages() {
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? msgs) {
      if (msgs == null) return;
      for (final msg in msgs) {
        final recMess = msg.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        _messageController.add({'topic': msg.topic, 'payload': payload});
      }
    });
  }

  void subscribe(String topic) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void unsubscribe(String topic) {
    _client?.unsubscribe(topic);
  }

  void publish(String topic, String payload) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void publishJson(String topic, Map<String, dynamic> data) {
    publish(topic, jsonEncode(data));
  }

  void disconnect() {
    _client?.disconnect();
  }

  void _onConnected() => _setState(AppMqttState.connected);
  void _onDisconnected() => _setState(AppMqttState.disconnected);
  void _onReconnected() => _setState(AppMqttState.connected);

  void _setState(AppMqttState state) {
    connectionState = state;
    _connectionStateController.add(state);
  }

  void dispose() {
    _connectionStateController.close();
    _messageController.close();
    _client?.disconnect();
  }
}
