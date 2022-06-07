import 'dart:ffi';
import 'dart:io';

import 'bindings.g.dart';

abstract class FlutterLedgerLib {
  static Bindings? _bindings;

  static void initialize() {
    final dylib = _dlOpenPlatformSpecific();

    final postCObject = NativeApi.postCObject.cast<Void>();

    _bindings = Bindings(dylib)..lb_store_dart_post_cobject(postCObject);
  }

  static Bindings get bindings {
    if (_bindings != null) {
      return _bindings!;
    } else {
      throw Exception("Library isn't loaded");
    }
  }

  static DynamicLibrary _dlOpenPlatformSpecific() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('flutter_ledger_lib.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('flutter_ledger_lib.dll');
    } else {
      throw Exception('Invalid platform');
    }
  }
}
