import 'dart:io';

///
/// Class that manage the deep links
///
class DeepLink {
  /// Return the Google Maps deep link
  static String get googleMaps {
    if (Platform.isAndroid) {
      return "com.google.android.apps.maps";
    } else {
      return "comgooglemaps://";
    }
  }

  /// Return the Waze deep link
  static String get waze {
    if (Platform.isAndroid) {
      return "com.waze";
    } else {
      return "waze://";
    }
  }

  /// Return the Plans deep link
  static String get plans => "http://maps.apple.com/";
}

///
/// Class that manage the navigation urls
///
class NavigationUrl {
  /// Return the Google Maps url
  static String get googleMaps {
    if (Platform.isAndroid) {
      return "http://maps.google.com/maps?daddr=";
    } else {
      return "comgooglemaps://?daddr=";
    }
  }

  /// Return the Waze url
  static String get waze {
    if (Platform.isAndroid) {
      return "https://waze.com/ul?";
    } else {
      return "waze://?";
    }
  }

  /// Return the Plans url
  static String get plans => "http://maps.apple.com/?daddr=";
}
