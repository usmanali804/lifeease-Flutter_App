import 'package:flutter/material.dart';

class HomeStatsProvider with ChangeNotifier {
  int tasksDue = 3;
  int waterPercent = 60;
  String mood = 'Happy';
  int sleepHours = 6;

  void updateStats({int? tasks, int? water, String? newMood, int? sleep}) {
    if (tasks != null) tasksDue = tasks;
    if (water != null) waterPercent = water;
    if (newMood != null) mood = newMood;
    if (sleep != null) sleepHours = sleep;
    notifyListeners();
  }
}
