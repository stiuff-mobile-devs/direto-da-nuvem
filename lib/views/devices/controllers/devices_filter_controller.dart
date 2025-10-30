import 'package:ddnuvem/models/group.dart';
import 'package:flutter/material.dart';

class DevicesFilterController extends ChangeNotifier {
  Set<Group> filters = {
  };

  addFilter(Group groupName) {
    filters.add(groupName);
    notifyListeners();
  }

  removeFilter(Group filterName) {
    filters.remove(filterName);
    notifyListeners();
  }
}