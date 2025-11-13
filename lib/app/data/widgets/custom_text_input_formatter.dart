import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Split into integer and decimal parts
    List<String> parts = cleanedText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add thousand separators to the integer part
    String formattedInteger = _addThousandSeparators(integerPart);

    // Combine the formatted integer and decimal parts
    String formattedText = '$formattedInteger$decimalPart';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _addThousandSeparators(String value) {
    if (value.isEmpty) return value;

    String result = '';
    int length = value.length;
    for (int i = 0; i < length; i++) {
      result += value[i];
      if ((length - i - 1) % 3 == 0 && i != length - 1) {
        result += ',';
      }
    }
    return result;
  }
}
