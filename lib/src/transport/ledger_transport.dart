import 'dart:ffi';

import 'package:synchronized/synchronized.dart';

import '../../flutter_ledger_lib.dart';
import '../ffi_utils.dart';

class LedgerTransport {
  final _lock = Lock();
  Pointer<Void>? _ptr;
  @override
  LedgerTransport._();

  static Future<LedgerTransport> create() async {
    final instance = LedgerTransport._();
    await instance._initialize();
    return instance;
  }

  Future<Pointer<Void>> clonePtr() => _lock.synchronized(() {
        if (_ptr == null) throw Exception('Jrpc transport use after free');

        final ptr = FlutterLedgerLib.bindings.ledger_transport_clone_ptr(
          _ptr!,
        );

        return ptr;
      });

  Future<void> freePtr() => _lock.synchronized(() {
        if (_ptr == null) return;

        FlutterLedgerLib.bindings.ledger_transport_free_ptr(
          _ptr!,
        );

        _ptr = null;
      });

  Future<void> _initialize() => _lock.synchronized(() async {
        final result = executeSync(
          () => FlutterLedgerLib.bindings.create_ledger_transport(),
        );

        _ptr = Pointer.fromAddress(result).cast<Void>();
      });

  Future<void> exchange() async {
    final ptr = await clonePtr();

    final result = await executeAsync(
      (port) => FlutterLedgerLib.bindings.ledger_exchange(
        port,
        ptr,
      ),
    );

    final id = cStringToDart(result);

    return;
  }
}
