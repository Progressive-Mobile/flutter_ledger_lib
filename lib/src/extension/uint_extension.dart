import 'dart:typed_data';

import 'package:eosdart/eosdart.dart';

extension UintList on int {
  Uint8List toUint8List([int length = 4]) {
    var number1 = this;
    String charValues = '0123456789ABCDEF';
    String stringAnswer = '';
    List<int> numericValues = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    int num2;
    List<int> ssc = List.generate(length * 2, (index) => 0);
    for (int i = 0; i < ssc.length; i++) {
      num2 = number1 ~/ 16;
      ssc[i] = number1 - (num2 * 16);
      number1 = num2;
    }
    for (int j = 0; j < ssc.length; j++) {
      for (int k = 0; k < 16; k++) {
        if (ssc[j] == numericValues[k]) {
          stringAnswer += charValues[k];
        }
      }
    }
    var reversedString = '';
    for (int i = stringAnswer.length - 1; i >= 0; i--) {
      reversedString = '$reversedString${stringAnswer[i]}';
    }
    return hexToUint8List(reversedString);
  }
}
