import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WarehouseChangeNotifier extends ChangeNotifier {
  void notifyChanged() {
    notifyListeners();
  }
}
