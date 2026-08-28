/// §22.2: money is always integer minor units (pence), never a `double`.
/// This is the one place that turns minor units into display text.
const _symbols = {'GBP': '£', 'USD': r'$', 'EUR': '€'};

String formatMoney(int minorUnits, String currency) {
  final symbol = _symbols[currency] ?? '$currency ';
  final sign = minorUnits < 0 ? '-' : '';
  final absMinor = minorUnits.abs();
  final major = absMinor ~/ 100;
  final minor = (absMinor % 100).toString().padLeft(2, '0');
  return '$sign$symbol$major.$minor';
}
