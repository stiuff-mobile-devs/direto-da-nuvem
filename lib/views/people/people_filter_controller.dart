import 'package:flutter/material.dart';

class PeopleFilterController extends ChangeNotifier {
  Set<String> filters = {};
  String searchQuery = '';

  addFilter(String privilege) {
    filters.add(privilege);
    notifyListeners();
  }

  removeFilter(String privilege) {
    filters.remove(privilege);
    notifyListeners();
  }

  void updateSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void clearSearch() => updateSearch('');
}
