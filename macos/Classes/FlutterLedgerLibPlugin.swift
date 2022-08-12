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
      ll_free_cstring(nil)

      ll_create_ledger_transport(nil)

      ll_ledger_transport_free_ptr(nil)

      ll_ledger_exchange(0, nil, 0, 0, 0, 0, nil)

      ll_store_dart_post_cobject(nil)

      ll_get_ledger_devices(0)

      ll_cstring_to_void_ptr(nil);
  }
}
