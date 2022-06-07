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
  late LedgerTransport ledgerTransport;

  @override
  void initState() {
    init();

    super.initState();
  }

  @override
  void dispose() {
    if (isInit) {
      ledgerTransport.freePtr();
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
          child: ElevatedButton(
            onPressed: () async {
              if (isInit) {
                ledgerTransport.exchange();
              }
            },
            child: const Text(
              'Get public key,',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    ledgerTransport = await LedgerTransport.create();
    setState(() {
      isInit = true;
    });
  }
}
