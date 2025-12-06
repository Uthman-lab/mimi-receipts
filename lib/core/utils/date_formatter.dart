import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayFormatWithTime = DateFormat('MMM dd, yyyy HH:mm');

  /// Format date for database storage (yyyy-MM-dd)
  static String formatForStorage(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date for display (MMM dd, yyyy)
  static String formatForDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Format date with time for display
  static String formatForDisplayWithTime(DateTime date) {
    return _displayFormatWithTime.format(date);
  }

  /// Parse date from storage format
  static DateTime parseFromStorage(String dateString) {
    return _dateFormat.parse(dateString);
  }
}



