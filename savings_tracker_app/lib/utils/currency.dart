import 'package:intl/intl.dart';

final NumberFormat _takaFormat = NumberFormat.currency(
  symbol: '৳',
  decimalDigits: 2,
);

String formatTaka(num amount) {
  return _takaFormat.format(amount.toDouble());
}
