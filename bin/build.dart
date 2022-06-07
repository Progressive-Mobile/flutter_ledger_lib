import 'dart:io';

Future<void> main(List<String> args) async {
  final flutterProjectDirectory = Directory.current.absolute.path;
  final rustProjectDirectory = '$flutterProjectDirectory/rust';

  Future<void> execute({
    required String executable,
    required List<String> arguments,
    Map<String, String>? environment,
    required String workingDirectory,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      environment: environment,
      workingDirectory: workingDirectory,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;

    if (exitCode != 0) exit(exitCode);
  }

  await execute(
    executable: 'make',
    arguments: ['init'],
    workingDirectory: rustProjectDirectory,
  );

  await execute(
    executable: 'make',
    arguments: ['all'],
    workingDirectory: rustProjectDirectory,
  );

  await execute(
    executable: 'flutter',
    arguments: ['pub', 'run', 'ffigen'],
    workingDirectory: flutterProjectDirectory,
  );
}
