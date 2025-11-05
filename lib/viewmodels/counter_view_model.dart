import 'package:flutter/foundation.dart';

import '../models/counter.dart';
import '../services/counter_service.dart';

/// CounterViewModel implements business logic and exposes observable state
/// for the view. It follows the ChangeNotifier pattern so UI can listen.
class CounterViewModel extends ChangeNotifier {
  final CounterService _service;
  Counter _counter = Counter();
  bool _isLoading = false;

  CounterViewModel({CounterService? service})
    : _service = service ?? CounterService() {
    _load();
  }

  int get value => _counter.value;
  bool get isLoading => _isLoading;

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    final loaded = await _service.load();
    _counter = Counter(value: loaded);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> increment() async {
    _counter.value++;
    notifyListeners();
    await _service.save(_counter.value);
  }

  Future<void> reset() async {
    _counter = Counter(value: 0);
    notifyListeners();
    await _service.save(0);
  }
}
