// log_manager.dart
import 'dart:async';

class LogManager {
  static final LogManager _instance = LogManager._internal();
  factory LogManager() => _instance;
  LogManager._internal();

  final StreamController<String> _controller = StreamController.broadcast();

  Stream<String> get logStream => _controller.stream;

  void addLog(String log) {
    _controller.add(log);
  }

  void dispose() {
    _controller.close();
  }
}
