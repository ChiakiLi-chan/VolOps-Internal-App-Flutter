import 'dart:io';
import 'package:flutter/material.dart';


typedef OnMessage = void Function(String message);
typedef OnStatusChange = void Function(String status);

class PhoneConnectionHandler {
  WebSocket? _socket;
  String status = 'Disconnected';
  String lastFromPc = '';

  OnMessage? onMessage;
  OnStatusChange? onStatusChange;
  VoidCallback? onDisconnected;

  PhoneConnectionHandler({this.onMessage, this.onStatusChange, this.onDisconnected});

  Future<void> connect(String wsUrl) async {
    _updateStatus('Connecting...');
    try {
      _socket = await WebSocket.connect(wsUrl);

      _updateStatus('Connected');

      _socket!.listen(
        (data) {
          lastFromPc = data.toString();
          onMessage?.call(lastFromPc);
        },
        onDone: () {
          _updateStatus('Disconnected');
          onDisconnected?.call(); // notify UI
        },
        onError: (_) {
          _updateStatus('Error');
          onDisconnected?.call(); // notify UI
        },
      );
    } catch (e) {
      _updateStatus('Failed to connect');
      onDisconnected?.call(); // notify UI
    }
  }

  void send(String message) {
    _socket?.add(message);
  }

  void dispose() {
    _socket?.close();
    _socket = null;
  }

  void _updateStatus(String newStatus) {
    status = newStatus;
    onStatusChange?.call(status);
  }
}
