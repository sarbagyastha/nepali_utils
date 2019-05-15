class NepaliNumber {
  static String from(int number, [bool formatWithComma = false]) {
    assert(number != null, 'Number cannot be null');
    String _number = number.toString();
    var _num = _number.replaceAllMapped(
      RegExp(r'\d'),
      (match) => _map[int.parse(match.group(0))][match.group(0)],
    );
    return formatWithComma ? NepaliNumber.formatWithComma(_num) : _num;
  }

  static String fromString(String number, [bool formatWithComma = false]) {
    assert(number != null, 'Number cannot be null');
    var _num = number.replaceAllMapped(
      RegExp(r'\d'),
      (match) => _map[int.parse(match.group(0))][match.group(0)],
    );
    return formatWithComma ? NepaliNumber.formatWithComma(_num) : _num;
  }

  static String formatWithComma(String number) {
    String _number = number;
    if (number.length > 3) {
      int j = number.length - 3;
      for (int i = number.length - 2; i > 0; i--) {
        if (number.length.isOdd) {
          if (i.isOdd && i != 1) {
            _number =
                _number.replaceFirst(number[i - 1], ',${number[i - 1]}', j);
            j -= 2;
          }
        } else {
          if (i.isEven && i != 1) {
            _number =
                _number.replaceFirst(number[i - 1], ',${number[i - 1]}', j);
            j -= 2;
          }
        }
      }
    }
    return _number;
  }

  static var _map = [
    {'0': '०'},
    {'1': '१'},
    {'2': '२'},
    {'3': '३'},
    {'4': '४'},
    {'5': '५'},
    {'6': '६'},
    {'7': '७'},
    {'8': '८'},
    {'9': '९'}
  ];
}
