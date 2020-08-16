class RoomieDates {
  static int get weekNum =>
     ((DateTime.now().millisecondsSinceEpoch -
          DateTime(2020, 5, 5).millisecondsSinceEpoch) ~/
          (7 * 24 * 60 * 60 * 1000)) + 1;
}