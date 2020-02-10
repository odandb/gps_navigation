import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:gps_navigation/src/maps/map.dart';
import 'package:gps_navigation/src/navigation_utils.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// Class to manage navigation with Waze
///
class Waze extends NavigationMap {
  /// Name of the application
  @override
  String get name => "Waze";

  ///
  /// Return true if Waze is available on the phone, false otherwise
  ///
  @override
  Future<bool> exist() async {
    try {
      await AppAvailability.checkAvailability(DeepLink.waze);
      return true;
    } catch (e) {
      return false;
    }
  }

  ///
  /// Launch the query
  ///
  /// Throw a [NavigationException] if the query can't be launch
  ///
  @override
  void action({
    String address,
    double latitude,
    double longitude,
  }) async {
    String query;

    // If the address exist, add it to the query
    if (address != null && address.isNotEmpty) {
      query = _getAddressQuery(address);
    } else {
      // If the address doesn't exist, add the location to the query
      query = _getLocationQuery(latitude, longitude);
    }

    if (await canLaunch(query)) {
      launch(query);
    } else {
      throw NavigationException();
    }
  }

  ///
  /// Return a Waze query to the destination address
  ///
  String _getAddressQuery(String address) {
    return Uri.encodeFull("${NavigationUrl.waze}q=$address&navigate=yes");
  }

  ///
  /// Return a Waze query to the destination location
  ///
  /// [latitude] and [longitude] are supposed to exist
  ///
  String _getLocationQuery(double latitude, double longitude) {
    return Uri.encodeFull(
      "${NavigationUrl.waze}ll=$latitude,$longitude&navigate=yes",
    );
  }
}
