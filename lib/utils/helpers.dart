import 'package:intl/intl.dart';

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
