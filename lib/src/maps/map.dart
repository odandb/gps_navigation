class NavigationException implements Exception {}

abstract class NavigationMap {
  String get name;

  Future<bool> exist();

  void action({String address, double latitude, double longitude});
}
