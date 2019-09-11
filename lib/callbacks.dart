import 'package:flutter/services.dart';

const _channel = const MethodChannel('callbacks');

typedef void MultiUseCallback(dynamic msg);
typedef void CancelListening();

int _nextCallbackId = 0;
Map<int, MultiUseCallback> _callbacksById = new Map();

Future<void> _methodCallHandler(MethodCall call) async {
  switch (call.method) {
    case 'callListener':
      _callbacksById[call.arguments["id"]](call.arguments["args"]);
      break;
    default:
      print(
          'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
  }
}

Future<CancelListening> startListening(MultiUseCallback callback) async {
  _channel.setMethodCallHandler(_methodCallHandler);

  int currentListenerId = _nextCallbackId++;
  _callbacksById[currentListenerId] = callback;

  await _channel.invokeMethod("startListening", currentListenerId);

  return () {
    _channel.invokeMethod("cancelListening", currentListenerId);
    _callbacksById.remove(currentListenerId);
  };
}
