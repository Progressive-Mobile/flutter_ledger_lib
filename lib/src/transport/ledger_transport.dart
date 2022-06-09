import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:convert/convert.dart';
import 'package:synchronized/synchronized.dart';

import '../../flutter_ledger_lib.dart';
import '../extension/uint_extension.dart';
import '../ffi_utils.dart';
import 'ledger_response.dart';

class LedgerTransport {
  static const _cla = 0xe0;
  static const _confCla = 0xb0;
  static const _insGetConf = 0x01;
  static const _insGetPk = 0x02;
  static const _insSign = 0x03;
  static const _ledgerSystemName = 'BOLOS';

  final _lock = Lock();
  Pointer<Void>? _ptr;
  @override
  LedgerTransport._();

  static Future<LedgerTransport> create() async {
    final instance = LedgerTransport._();
    try {
      await instance._initialize();
      final name = await instance.getAppName();
      if (name == _ledgerSystemName) {
        await instance.freePtr();
        throw const LedgerError.responseError(statusWord: StatusWord.appIsNotOpen);
      }
      return instance;
    } on LedgerError {
      rethrow;
    } catch (err) {
      throw LedgerError.connectionError(origMessage: err.toString());
    }
  }

  Future<Pointer<Void>> clonePtr() => _lock.synchronized(() {
        if (_ptr == null) throw Exception('Ledger transport use after free');

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

  Future<String> getKey(int keyIndex, {bool verify = false}) async {
    final ptr = await clonePtr();
    final keyIndexRawValue = jsonEncode(keyIndex.toUint8List());

    return _executeLedgerQuery(
      () async {
        final result = await executeAsync(
          (port) => FlutterLedgerLib.bindings.ledger_exchange(
            port,
            ptr,
            _cla,
            _insGetPk,
            verify ? 0x01 : 0x00,
            0x00,
            keyIndexRawValue.toNativeUtf8().cast<Char>(),
          ),
        );
        final string = cStringToDart(result);
        final json = jsonDecode(string) as Map<String, dynamic>;
        final response = LedgerResponse.fromJson(json);

        if (response.statusWord != StatusWord.success) {
          throw LedgerError.responseError(statusWord: response.statusWord);
        }

        final key = response.data;

        return key.isNotEmpty ? hex.encode(key.skip(1).take(key[0]).toList()) : '';
      },
    );
  }

  Future<String> signMessage({
    required int keyIndex,
    required String address,
    required String destination,
    required int decimals,
    required int amount,
    required String asset,
  }) async {
    final ptr = await clonePtr();
    final assetRawBytes = Uint8List.fromList(asset.codeUnits);
    final list32 = List.generate(32 - assetRawBytes.length, (index) => 0);
    list32.insertAll(list32.length, assetRawBytes);

    final parts = destination.split(':');
    final workChainBytes = Uint8List.fromList([int.parse(parts[0])]);
    final addressBytes = hex.decode(address);
    final assetBytes = Uint8List.fromList(list32);
    final destinationBytes = hex.decode(parts[1]);
    final amountBytes = amount.toUint8List(8);

    final data = jsonEncode(Uint8List.fromList([
      ...keyIndex.toUint8List(),
      ...amountBytes,
      ...assetBytes,
      decimals,
      ...workChainBytes,
      ...destinationBytes,
      ...addressBytes,
    ]));

    return _executeLedgerQuery(
      () async {
        final result = await executeAsync(
          (port) => FlutterLedgerLib.bindings.ledger_exchange(
            port,
            ptr,
            _cla,
            _insSign,
            0x00,
            0x00,
            data.toNativeUtf8().cast<Char>(),
          ) ,
        );

        final string = cStringToDart(result);
        final key = (jsonDecode(string) as List<dynamic>).cast<int>();

        return key.isNotEmpty ? hex.encode(key.skip(1).take(key[0]).toList()) : '';
      },
    );
  }

  Future<String> getAppName() async {
    final ptr = await clonePtr();
    final keyIndexRawValue = jsonEncode([]);

    return _executeLedgerQuery(
      () async {
        final result = await executeAsync(
          (port) => FlutterLedgerLib.bindings.ledger_exchange(
            port,
            ptr,
            _confCla,
            _insGetConf,
            0x00,
            0x00,
            keyIndexRawValue.toNativeUtf8().cast<Char>(),
          ),
        );
        final string = cStringToDart(result);
        final json = jsonDecode(string) as Map<String, dynamic>;
        final response = LedgerResponse.fromJson(json);

        if (response.statusWord != StatusWord.success) {
          throw LedgerError.responseError(statusWord: response.statusWord);
        }

        final nameBytes = response.data.skip(2).take(response.data[1]).toList();
        final name = String.fromCharCodes(nameBytes);

        return name;
      },
    );
  }

  Future<T> _executeLedgerQuery<T>(Future<T> Function() query) async {
    try {
      return await query();
    } on LedgerError {
      rethrow;
    } catch (err) {
      throw const LedgerError.responseError(statusWord: StatusWord.unknownError);
    }
  }
}
