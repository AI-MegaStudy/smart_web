String formatPrice(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < text.length; index += 1) {
    final reverseIndex = text.length - index;
    buffer.write(text[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return '$buffer원';
}

String formatKg(double value) {
  return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
}
