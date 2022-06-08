import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'bindings.dart';
import 'model/execution_result.dart';

int executeSync(Pointer<Void> Function() function) {
  final ptr = function();
  final executionResult = ptr.cast<ExecutionResult>().ref;

  try {
    return executionResult.handle();
  } finally {
    FlutterLedgerLib.bindings.free_execution_result(ptr);
  }
}

Future<int> executeAsync(void Function(int port) function) async {
  final receivePort = ReceivePort();
  final completer = Completer<int>();

  receivePort.cast<int>().listen((data) {
    final ptr = Pointer.fromAddress(data).cast<Void>();
    final executionResult = ptr.cast<ExecutionResult>().ref;

    try {
      final result = executionResult.handle();
      completer.complete(result);
    } catch (err) {
      completer.completeError(err);
    } finally {
      FlutterLedgerLib.bindings.free_execution_result(ptr);
      receivePort.close();
    }
  });

  function(receivePort.sendPort.nativePort);

  return completer.future;
}

String cStringToDart(int address) {
  final ptr = Pointer.fromAddress(address).cast<Char>();

  final string = ptr.cast<Utf8>().toDartString();

  FlutterLedgerLib.bindings.free_cstring(ptr);

  return string;
}

String? optionalCStringToDart(int address) {
  if (Pointer.fromAddress(address) == nullptr) {
    return null;
  } else {
    return cStringToDart(address);
  }
}
