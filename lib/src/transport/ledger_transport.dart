import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:convert/convert.dart';

import '../../flutter_ledger_lib.dart';
import '../extension/uint_extension.dart';
import '../ffi_utils.dart';
import 'ledger_response.dart';

final _nativeFinalizer = NativeFinalizer(
    FlutterLedgerLib.instance.bindings.addresses.ll_ledger_transport_free_ptr);

class LedgerTransport implements Finalizable {
  static const _cla = 0xe0;
  static const _confCla = 0xb0;
  static const _insGetConf = 0x01;
  static const _insGetPk = 0x02;
  static const _insSign = 0x03;
  static const _ledgerSystemName = 'BOLOS';

  late Pointer<Void> _ptr;

  @override
  LedgerTransport(
    String path,
  ) {
    final result = executeSync(
      () => FlutterLedgerLib.instance.bindings
          .ll_create_ledger_transport(path.toNativeUtf8().cast<Char>()),
    );

    _ptr = toPtrFromAddress(result as String);

    _nativeFinalizer.attach(this, _ptr);
  }

  static Future<LedgerTransport> create({
    required String path,
    required String appName,
  }) async {
    final instance = LedgerTransport(path);
    try {
      final name = await instance.getAppName();
      if (name != appName) {
        throw const LedgerError.responseError(
            statusWord: StatusWord.appIsNotOpen);
      }
      return instance;
    } on LedgerError {
      rethrow;
    } catch (err) {
      throw LedgerError.connectionError(origMessage: err.toString());
    }
  }

  static Future<List<LedgerDevice>> getLedgerDevices() async {
    final result = await executeAsync(
      (port) => FlutterLedgerLib.instance.bindings.ll_get_ledger_devices(
        port,
      ),
    );
    final string = cStringToDart(result);
    final json = jsonDecode(string) as List<dynamic>;

    return json
        .map((e) => LedgerDevice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> getKey(int keyIndex, {bool verify = false}) async {
    final keyIndexRawValue = jsonEncode(keyIndex.toUint8List());

    return _executeLedgerQuery(
      () async {
        final result = await executeAsync(
          (port) => FlutterLedgerLib.instance.bindings.ll_ledger_exchange(
            port,
            _ptr,
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

        return key.isNotEmpty
            ? hex.encode(key.skip(1).take(key[0]).toList())
            : '';
      },
    );
  }

  Future<String> signMessage({
    required int keyIndex,
    required List<int> message,
    required String address,
    required int decimals,
    required int amount,
    required String asset,
  }) async {
    final assetRawBytes = Uint8List.fromList(asset.codeUnits);
    final list32 = List.generate(32 - assetRawBytes.length, (index) => 0);
    list32.insertAll(list32.length, assetRawBytes);

    final parts = address.split(':');
    final workChainBytes = Uint8List.fromList([int.parse(parts[0])]);
    final assetBytes = Uint8List.fromList(list32);
    final destinationBytes = hex.decode(parts[1]);
    final amountBytes = amount.toUint8List(16);

    final data = jsonEncode(Uint8List.fromList([
      ...keyIndex.toUint8List(),
      ...amountBytes,
      ...assetBytes,
      decimals,
      ...workChainBytes,
      ...destinationBytes,
      ...message,
    ]));

    return _executeLedgerQuery(
      () async {
        final result = await executeAsync(
          (port) => FlutterLedgerLib.instance.bindings.ll_ledger_exchange(
            port,
            _ptr,
            _cla,
            _insSign,
            0x00,
            0x00,
            data.toNativeUtf8().cast<Char>(),
          ),
        );
        final string = cStringToDart(result);
        final json = jsonDecode(string) as Map<String, dynamic>;
        final response = LedgerResponse.fromJson(json);

        if (response.statusWord != StatusWord.success) {
          throw LedgerError.responseError(statusWord: response.statusWord);
        }
        final signature = response.data;

        return signature.isNotEmpty
            ? hex.encode(signature.skip(1).take(signature[0]).toList())
            : '';
      },
    );
  }

  Future<String> getAppName() async {
    final keyIndexRawValue = jsonEncode([]);

    return _executeLedgerQuery(
      () async {
        final result = await executeAsync(
          (port) => FlutterLedgerLib.instance.bindings.ll_ledger_exchange(
            port,
            _ptr,
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
      throw const LedgerError.responseError(
          statusWord: StatusWord.unknownError);
    }
  }
}
