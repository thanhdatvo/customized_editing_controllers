part of customized_editing_controllers;

class NumberEditingController extends TextEditingController {
  Function afterChange = (String text, double value) {};
  Function beforeChange = (String text) {};
  String _lastText;
  int precision;
  int _lastPrecision;
  String decimalSeparator;
  NumberEditingController(
      {double initialValue = 0.0,
      this.precision = 0,
      this.decimalSeparator = '.'})
      : assert(precision >= 0 && precision <= 8) {
    RegExp regExp;
    _lastPrecision = precision;
    addListener(() {
      /// same as addListenner();
      beforeChange(text);
      if (text == _lastText) return;

      if (precision == 0) {
        regExp = RegExp(r'^\d*$');
      } else {
        regExp = RegExp(r'^\d*\' +
            decimalSeparator +
            r'?\d{0,' +
            precision.toString() +
            r'}$');
      }
      String finalText = text;
      TextSelection tempSelection = selection;

      bool isStartFromNull = _lastText == null;
      if (!isStartFromNull) {
        ///
        /// if update precision to smaller
        /// cut off watsed numbers
        if (_lastPrecision != precision) {
          int decimalPosition = finalText.lastIndexOf(decimalSeparator);
          int currentTextPrecision = finalText.length - decimalPosition - 1;

          /// only if has decimal,
          /// when increase decimal
          /// and  when out of decimal place
          if (decimalPosition > -1 &&
              _lastPrecision > precision &&
              currentTextPrecision > precision) {
            finalText =
                double.tryParse(finalText).toStringAsFixed(precision) ?? '';
            tempSelection = TextSelection.fromPosition(
                TextPosition(offset: finalText.length + 1));
          }
          _lastPrecision = precision;
        }

        bool hasNewDecimalSeparator =
            _lastText.indexOf(decimalSeparator) == -1 &&
                finalText.indexOf(decimalSeparator) > -1;
        bool onlyOneDecimalSeparator = finalText.indexOf(decimalSeparator) ==
            finalText.lastIndexOf(decimalSeparator);
        if (hasNewDecimalSeparator && onlyOneDecimalSeparator) {
          bool isDecimalSeparatorFirst =
              finalText.indexOf(decimalSeparator) == 0;

          ///
          /// the first text is decimal place
          ///
          if (isDecimalSeparatorFirst) {
            finalText = '0' + finalText;
          }

          int decimalPosition = finalText.lastIndexOf(decimalSeparator);
          int currentTextPrecision = finalText.length - decimalPosition - 1;

          ///
          /// if add  decimal separator to middle
          /// cut off watsed numbers
          // if (!isCursorEnd) {
          if (currentTextPrecision > precision) {
            finalText =
                double.tryParse(finalText).toStringAsFixed(precision) ?? '';
          }
          if (isDecimalSeparatorFirst)
            tempSelection = TextSelection.fromPosition(TextPosition(
                offset: finalText.lastIndexOf(decimalSeparator) + 1));
        }
      }

      ///
      /// if ok
      /// get number out
      if (regExp.hasMatch(finalText)) {
        _lastText = finalText;
        double number = _processText(finalText);

        ///
        /// afterChange is not same as addListenner();
        /// it only update with conditions
        afterChange(finalText, number);
      }

      ///
      /// if not ok
      /// reset text and selection
      else {
        finalText = _lastText;
      }
      bool hasOneMoreDecimalSeparator =
          text.indexOf(decimalSeparator) != text.lastIndexOf(decimalSeparator);

      bool decimalKeepPosition = _lastText.lastIndexOf(decimalSeparator) ==
          text.lastIndexOf(decimalSeparator);

      bool addedNumberOrSeparator = _lastText.length < text.length;

      bool hasMoreNumberAfterDecimal =
          addedNumberOrSeparator && decimalKeepPosition;

      bool addedManyNumbers = text.length - _lastText.length > 1;

      int finalPosition = finalText.length;
      bool alreadyEndCursorPosition =
          tempSelection.baseOffset > finalText.length;

      if (alreadyEndCursorPosition) {
        /// back to end cursor
        tempSelection =
            TextSelection.fromPosition(TextPosition(offset: finalPosition));
      } else if (hasOneMoreDecimalSeparator) {
        /// keep the cursor at current position
        tempSelection = TextSelection.fromPosition(
            TextPosition(offset: tempSelection.baseOffset - 1));
      } else if (hasMoreNumberAfterDecimal) {
        /// if input many character behind
        /// move cursor to the end
        if (hasMoreNumberAfterDecimal && addedManyNumbers) {
          tempSelection =
              TextSelection.fromPosition(TextPosition(offset: finalPosition));
        } else {
          /// keep the cursor at current position
          tempSelection = TextSelection.fromPosition(
              TextPosition(offset: tempSelection.baseOffset - 1));
        }
      }
      value = value.copyWith(text: finalText, selection: tempSelection);
    });
  }

  void updatePrecision(int newPosition) {
    _lastPrecision = precision;
    precision = newPosition;
  }

  double _processText(String finalText) {
    ///
    /// if last position is a separator
    ///
    if (finalText != null &&
        finalText.length >= 2 &&
        finalText.indexOf(decimalSeparator) == finalText.length) {
      return double.tryParse(finalText.substring(0, finalText.length - 2));
    }
    return double.tryParse(finalText);
  }
}
