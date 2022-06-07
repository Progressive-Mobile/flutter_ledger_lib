import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_ledger_lib/flutter_ledger_lib.dart';

Future<void> main() async {
  FlutterLedgerLib.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isInit = false;
  LedgerTransport? ledgerTransport;
  final keyNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    if (isInit) {
      ledgerTransport?.freePtr();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: ledgerTransport == null ? connectLedger : null,
                child: const Text(
                  'Connect ledger',
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: keyNotifier,
                builder: (context, value, _) => SizedBox(
                  height: 50,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: value == null
                        ? const SizedBox()
                        : value.isEmpty
                            ? const CircularProgressIndicator()
                            : Text(value),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: ledgerTransport != null
                    ? () async {
                        keyNotifier.value = '';
                        final key = await ledgerTransport!.getKey();
                        if (key.isNotEmpty) {
                          keyNotifier.value = key;
                        } else {
                          keyNotifier.value = null;
                        }
                      }
                    : null,
                child: const Text(
                  'Get public key',
                ),
              ),
              ElevatedButton(
                onPressed: ledgerTransport != null ? disconnectLedger : null,
                child: const Text(
                  'Disconnect ledger',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> connectLedger() async {
    ledgerTransport = await LedgerTransport.create();
    setState(() {});
  }

  Future<void> disconnectLedger() async {
    await ledgerTransport?.freePtr();
    keyNotifier.value = null;
    setState(() {
      ledgerTransport = null;
    });
  }
}
