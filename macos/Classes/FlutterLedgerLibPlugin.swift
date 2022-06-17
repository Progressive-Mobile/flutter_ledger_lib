import Cocoa
import FlutterMacOS

public class FlutterLedgerLibPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_ledger_lib", binaryMessenger: registrar.messenger)
    let instance = FlutterLedgerLibPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func dummyMethodToEnforceBundling() {
      // This will never be executed 
      free_execution_result(nil)

      free_cstring(nil)

      create_ledger_transport(nil)

      ledger_transport_clone_ptr(nil)

      ledger_transport_free_ptr(nil)

      ledger_exchange(0, nil, 0, 0, 0, 0, nil)

      lb_store_dart_post_cobject(nil)

      get_ledger_devices(0)
  }
}
