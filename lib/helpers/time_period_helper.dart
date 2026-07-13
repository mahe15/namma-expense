class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange(this.start, this.end);

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(seconds: 1))) && 
           date.isBefore(end.add(const Duration(seconds: 1)));
  }
}

class TimePeriodHelper {
  static int _daysInMonth(int year, int month) {
    // 0 returns the last day of the previous month.
    return DateTime(year, month + 1, 0).day;
  }

  static TimeRange getWeekRange(DateTime now, int startOfWeek) {
    // startOfWeek: 1 = Monday, ..., 7 = Sunday
    // now.weekday is 1-7
    int daysToSubtract = now.weekday - startOfWeek;
    if (daysToSubtract < 0) {
      daysToSubtract += 7;
    }
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return TimeRange(start, end);
  }

  static TimeRange getMonthRange(DateTime now, int startOfMonthDay) {
    // Determine if the period started in the current month or previous month.
    // The start day for the current month:
    int curDays = _daysInMonth(now.year, now.month);
    int curStartDay = startOfMonthDay > curDays ? curDays : startOfMonthDay;
    final curPeriodStart = DateTime(now.year, now.month, curStartDay);

    DateTime start;
    DateTime nextPeriodStart;

    if (now.isBefore(curPeriodStart)) {
      // Period started in the previous month
      int prevYear = now.year;
      int prevMonth = now.month - 1;
      if (prevMonth < 1) {
        prevMonth = 12;
        prevYear -= 1;
      }
      int prevDays = _daysInMonth(prevYear, prevMonth);
      int prevStartDay = startOfMonthDay > prevDays ? prevDays : startOfMonthDay;
      start = DateTime(prevYear, prevMonth, prevStartDay);
      nextPeriodStart = curPeriodStart;
    } else {
      // Period started in the current month
      start = curPeriodStart;
      int nextYear = now.year;
      int nextMonth = now.month + 1;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear += 1;
      }
      int nextDays = _daysInMonth(nextYear, nextMonth);
      int nextStartDay = startOfMonthDay > nextDays ? nextDays : startOfMonthDay;
      nextPeriodStart = DateTime(nextYear, nextMonth, nextStartDay);
    }

    final end = nextPeriodStart.subtract(const Duration(seconds: 1));
    return TimeRange(start, end);
  }

  // Generate historical "month" start dates for the stats screen selector
  // e.g., if now is March 15, and startOfMonth=10, 
  // index 0 = Feb 10 - Mar 9 (Current)
  // index 1 = Jan 10 - Feb 9 (Previous)
  static DateTime getHistoricalMonthStart(DateTime now, int monthsAgo, int startOfMonthDay) {
    DateTime currentPeriodStart = getMonthRange(now, startOfMonthDay).start;
    DateTime targetStart = currentPeriodStart;
    for (int i = 0; i < monthsAgo; i++) {
      targetStart = getMonthRange(targetStart.subtract(const Duration(seconds: 1)), startOfMonthDay).start;
    }
    return targetStart;
  }

  static TimeRange getYearRange(DateTime now, int startOfYearMonth) {
    int year = now.year;
    if (now.month < startOfYearMonth) {
      year -= 1;
    }
    final start = DateTime(year, startOfYearMonth, 1);
    final end = DateTime(year + 1, startOfYearMonth, 1).subtract(const Duration(seconds: 1));
    return TimeRange(start, end);
  }
}
