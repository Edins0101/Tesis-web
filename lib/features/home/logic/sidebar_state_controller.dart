import 'package:flutter/foundation.dart';

class SidebarStateController extends ChangeNotifier {
  SidebarStateController._();

  static final SidebarStateController instance = SidebarStateController._();

  bool _expanded = false;
  bool _pinned = false;

  bool get expanded => _expanded;
  bool get pinned => _pinned;
  bool get isOpen => _expanded || _pinned;

  void setHoverExpanded(bool value) {
    if (_pinned || _expanded == value) {
      return;
    }
    _expanded = value;
    notifyListeners();
  }

  void togglePin() {
    _pinned = !_pinned;
    _expanded = _pinned;
    notifyListeners();
  }
}
