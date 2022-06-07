#ifndef FLUTTER_PLUGIN_FLUTTER_LEDGER_LIB_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_LEDGER_LIB_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_ledger_lib {

class FlutterLedgerLibPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterLedgerLibPlugin();

  virtual ~FlutterLedgerLibPlugin();

  // Disallow copy and assign.
  FlutterLedgerLibPlugin(const FlutterLedgerLibPlugin&) = delete;
  FlutterLedgerLibPlugin& operator=(const FlutterLedgerLibPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_ledger_lib

#endif  // FLUTTER_PLUGIN_FLUTTER_LEDGER_LIB_PLUGIN_H_
