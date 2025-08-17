import 'package:flutter/material.dart';

class PeopleFilterController extends ChangeNotifier {
  Set<String> filters = {};

  addFilter(String privilege) {
    filters.add(privilege);
    notifyListeners();
  }

  removeFilter(String privilege) {
    filters.remove(privilege);
    notifyListeners();
  }
}
