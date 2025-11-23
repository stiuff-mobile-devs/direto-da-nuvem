import 'package:ddnuvem/models/group.dart';
import 'package:flutter/material.dart';

class DevicesFilterController extends ChangeNotifier {
  Set<Group> filters = {};

  addFilter(Group group) {
    filters.add(group);
    notifyListeners();
  }

  removeFilter(Group filterGroup) {
    filters.remove(filterGroup);
    notifyListeners();
  }
}