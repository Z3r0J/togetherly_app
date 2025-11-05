/// A tiny service that would normally persist/load the counter.
/// For now it keeps the value in memory. Replace with SharedPreferences or
/// a backend later.
class CounterService {
  int _value = 0;

  Future<int> load() async {
    // simulate delay
    await Future.delayed(const Duration(milliseconds: 50));
    return _value;
  }

  Future<void> save(int value) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _value = value;
  }
}
