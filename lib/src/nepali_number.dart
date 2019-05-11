class NepaliNumber {
  final int _number;
  NepaliNumber(this._number);

  String get convert {
    String number = _number.toString();
    var _map = [
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
    return number.replaceAllMapped(
      RegExp(r'\d'),
      (match) => _map[int.parse(match.group(0))][match.group(0)],
    );
  }
}
