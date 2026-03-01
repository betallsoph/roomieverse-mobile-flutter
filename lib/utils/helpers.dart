import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats number with dot separators while typing (5000000 → 5.000.000).
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format with dot separators
    final formatted = _addDotSeparators(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _addDotSeparators(String digits) {
    final buffer = StringBuffer();
    final len = digits.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Strips dots from formatted currency string to get raw number for DB storage.
String stripCurrencyDots(String formatted) {
  return formatted.replaceAll('.', '');
}

String formatPrice(String? price) {
  if (price == null || price.isEmpty) return 'Thương lượng';
  // Try parsing as number and formatting
  final num? parsed = num.tryParse(price.replaceAll(RegExp(r'[^\d]'), ''));
  if (parsed != null && parsed >= 1000000) {
    final millions = parsed / 1000000;
    return '${millions.toStringAsFixed(millions.truncateToDouble() == millions ? 0 : 1)} triệu/tháng';
  }
  return price;
}

String formatDate(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '';
  try {
    final dt = DateTime.parse(isoString);
    return DateFormat('dd/MM/yyyy').format(dt);
  } catch (_) {
    return isoString;
  }
}

String timeAgo(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '';
  try {
    final dt = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30} tháng trước';
    return '${diff.inDays ~/ 365} năm trước';
  } catch (_) {
    return isoString;
  }
}

String categoryLabel(String category) {
  switch (category) {
    case 'roommate':
      return 'Tìm bạn ở ghép';
    case 'roomshare':
      return 'Phòng share';
    case 'short-term':
      return 'Ngắn ngày';
    case 'sublease':
      return 'Sang lại';
    default:
      return category;
  }
}

String communityCategoryLabel(String category) {
  switch (category) {
    case 'tips':
      return 'Tips';
    case 'drama':
      return 'Drama';
    case 'review':
      return 'Review';
    case 'pass-do':
      return 'Pass đồ';
    case 'blog':
      return 'Blog';
    default:
      return category;
  }
}
