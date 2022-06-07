#include "include/flutter_ledger_lib/flutter_ledger_lib_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_ledger_lib_plugin.h"

void FlutterLedgerLibPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_ledger_lib::FlutterLedgerLibPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
