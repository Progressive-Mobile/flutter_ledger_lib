import 'package:freezed_annotation/freezed_annotation.dart';

enum StatusWord {
  @JsonValue(0x9000)
  success,
  @JsonValue(0x6985)
  cancelled,
  @JsonValue(0x6b0c)
  inactiveDevice,
  @JsonValue(0x6c66)
  notAllowed,
  @JsonValue(0x6d00)
  unsupported,
  @JsonValue(0x6511)
  appIsNotOpen,
  unknownError;

  @override
  String toString() {
    switch (this) {
      case StatusWord.success:
        return 'success';
      case StatusWord.cancelled:
        return 'cancelled';
      case StatusWord.inactiveDevice:
        return 'inactiveDevice';
      case StatusWord.notAllowed:
        return 'notAllowed';
      case StatusWord.unsupported:
        return 'unsupported';
      case StatusWord.appIsNotOpen:
        return 'appIsNotOpen';
      case StatusWord.unknownError:
        return 'unknownError';
    }
  }
}
