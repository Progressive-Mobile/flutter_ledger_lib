import 'dart:ffi';
import 'dart:io';

import 'bindings.g.dart';

class FlutterLedgerLib {
  static FlutterLedgerLib? _instance;

  final Bindings? _bindings;

  FlutterLedgerLib._()
      : _bindings = Bindings(_dlOpenPlatformSpecific())
          ..ll_store_dart_post_cobject(NativeApi.postCObject.cast<Void>());

  static FlutterLedgerLib get instance => _instance ??= FlutterLedgerLib._();

  Bindings get bindings {
    if (_bindings != null) {
      return _bindings!;
    } else {
      throw Exception("Library isn't loaded");
    }
  }

  static DynamicLibrary _dlOpenPlatformSpecific() {
    if (Platform.isMacOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('flutter_ledger_lib.dll');
    } else {
      throw Exception('Invalid platform');
    }
  }
}
