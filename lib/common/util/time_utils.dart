class TimeUtils {
  TimeUtils._();

  static String getStandardNowTime() {
    return getStandardTime(DateTime.now());
  }

  static String getStandardTime(DateTime dateTime) {
    final String y = _fourDigits(dateTime.year);
    final String m = _twoDigits(dateTime.month);
    final String d = _twoDigits(dateTime.day);
    final String h = _twoDigits(dateTime.hour);
    final String min = _twoDigits(dateTime.minute);
    final String sec = _twoDigits(dateTime.second);
    return '$y-$m-$d $h:$min:$sec';
  }
}

String _fourDigits(int n) {
  final int absN = n.abs();
  final String sign = n < 0 ? '-' : '';
  if (absN >= 1000) return '$n';
  if (absN >= 100) return '${sign}0$absN';
  if (absN >= 10) return '${sign}00$absN';
  return '${sign}000$absN';
}

String _sixDigits(int n) {
  assert(n < -9999 || n > 9999);
  final int absN = n.abs();
  final String sign = n < 0 ? '-' : '+';
  if (absN >= 100000) return '$sign$absN';
  return '${sign}0$absN';
}

String _threeDigits(int n) {
  if (n >= 100) return '$n';
  if (n >= 10) return '0$n';
  return '00$n';
}

String _twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}
