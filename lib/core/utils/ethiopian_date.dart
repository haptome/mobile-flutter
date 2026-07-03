// Converts a Gregorian DateTime to Ethiopian calendar and formats it.
// Algorithm based on the Coptic/Ethiopic calendar arithmetic.

const List<String> _ethMonths = [
  'መስከረም', // 1
  'ጥቅምት',  // 2
  'ህዳር',   // 3
  'ታህሳስ',  // 4
  'ጥር',    // 5
  'የካቲት',  // 6
  'መጋቢት',  // 7
  'ሚያዚያ',  // 8
  'ግንቦት',  // 9
  'ሰኔ',    // 10
  'ሐምሌ',   // 11
  'ነሐሴ',   // 12
  'ጳጉሜ',   // 13 (short intercalary month)
];

/// Returns [year, month, day] in the Ethiopian calendar.
List<int> gregorianToEthiopian(DateTime date) {
  final int gYear = date.year;
  final int gMonth = date.month;
  final int gDay = date.day;

  // JDN of the Gregorian date
  final int jdn = _gregorianToJdn(gYear, gMonth, gDay);

  // Ethiopian epoch: 1 Meskerem 1 EE = 29 August 8 CE (Julian) = JDN 1724221
  const int ethEpoch = 1724221;

  final int r = (jdn - ethEpoch) % 1461; // days within a 4-year cycle
  final int n = r % 365 + 365 * (r ~/ 1460);

  final int ethYear = 4 * ((jdn - ethEpoch) ~/ 1461) + r ~/ 365 - r ~/ 1460;
  final int ethMonth = n ~/ 30 + 1;
  final int ethDay = n % 30 + 1;

  return [ethYear, ethMonth, ethDay];
}

int _gregorianToJdn(int y, int m, int d) {
  return (1461 * (y + 4800 + (m - 14) ~/ 12)) ~/ 4 +
      (367 * (m - 2 - 12 * ((m - 14) ~/ 12))) ~/ 12 -
      (3 * ((y + 4900 + (m - 14) ~/ 12) ~/ 100)) ~/ 4 +
      d -
      32075;
}

/// Formats [date] as an Ethiopian calendar string (e.g. "፲፭ መስከረም ፳፻፲፮").
/// Falls back to Gregorian dd/mm/yyyy for non-Amharic locales.
String formatStartDate(DateTime date, {bool amharic = false}) {
  if (!amharic) {
    return '${date.day}/${date.month}/${date.year}';
  }
  final eth = gregorianToEthiopian(date);
  final year = eth[0];
  final month = eth[1].clamp(1, 13) - 1;
  final day = eth[2];
  final monthName = _ethMonths[month];
  return '$day $monthName $year';
}
