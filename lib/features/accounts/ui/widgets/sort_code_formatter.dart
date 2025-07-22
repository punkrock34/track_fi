import 'package:flutter/services.dart';

class SortCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text.replaceAll('-', '');
    
    if (text.length <= 2) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 4) {
      return newValue.copyWith(
        text: '${text.substring(0, 2)}-${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else {
      return newValue.copyWith(
        text: '${text.substring(0, 2)}-${text.substring(2, 4)}-${text.substring(4)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
  }
}
