int getModifier(int value) {
  return (value - 10) ~/ 2;
}

int getProfBonus(int level) {
  return ((level - 1) ~/ 4) + 2;
}

List<Map<String, dynamic>> parseTable(String table) {
  List<Map<String, dynamic>> result = [];

  List<String> rows = table.trim().split('\n');

  List<String> headers = rows[0]
      .split('|')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  for (var i = 1; i < rows.length; i++) {
    List<String> rowValues = rows[i]
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (rowValues.length != headers.length) {
      throw const FormatException('Row does not match header length');
    }

    Map<String, dynamic> rowMap = {};
    for (var j = 0; j < headers.length; j++) {
      rowMap[headers[j]] = _parseValue(rowValues[j]);
    }
    result.add(rowMap);
  }

  return result;
}

dynamic _parseValue(String value) {
  if (int.tryParse(value) != null) return int.parse(value);
  if (double.tryParse(value) != null) return double.parse(value);
  return value;
}
