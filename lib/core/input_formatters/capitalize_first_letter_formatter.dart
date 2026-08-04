import 'package:flutter/services.dart';

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  const CapitalizeFirstLetterFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || !newValue.composing.isCollapsed) {
      return newValue;
    }

    final firstCharacter = RegExp(r'\S').firstMatch(newValue.text);
    if (firstCharacter == null) return newValue;

    final index = firstCharacter.start;
    final original = newValue.text.substring(index, index + 1);
    final uppercase = original.toUpperCase();
    if (original == uppercase) return newValue;

    final updatedText = newValue.text.replaceRange(index, index + 1, uppercase);
    final offsetDelta = uppercase.length - original.length;

    int adjustOffset(int offset) {
      if (offset < 0 || offset <= index) return offset;
      return offset + offsetDelta;
    }

    return newValue.copyWith(
      text: updatedText,
      selection: TextSelection(
        baseOffset: adjustOffset(newValue.selection.baseOffset),
        extentOffset: adjustOffset(newValue.selection.extentOffset),
        affinity: newValue.selection.affinity,
        isDirectional: newValue.selection.isDirectional,
      ),
      composing: TextRange.empty,
    );
  }
}
