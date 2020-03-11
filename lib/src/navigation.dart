import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gps_navigation/src/maps/google_maps.dart';
import 'package:gps_navigation/src/maps/map.dart';
import 'package:gps_navigation/src/maps/plans.dart';
import 'package:gps_navigation/src/maps/waze.dart';
import 'package:gps_navigation/src/navigation_options.dart';

///
/// Class that allow the gps navigation to a destination via a modal sheet
///
class GpsNavigation {
  static final _instance = GpsNavigation._();

  GpsNavigation._();

  ///
  /// Return the static instance of the class
  ///
  factory GpsNavigation() => _instance;

  ///
  /// Show a modal bottom sheet with a list of [ListTile], each representing a navigation application available on the device
  ///
  /// The navigation application available are:
  ///
  /// - Android: Google Maps and Waze
  /// - iOS: Google Maps, Waze and Plans
  ///
  /// If no navigation application is available, the sheet is not displayed
  ///
  /// - [context] is needed to display the modal bottom sheet
  /// - [options] is use to customize the modal bottom sheet
  /// - [address] is the postal address where you want to navigate to. Can be null
  /// - [latitude] and [longitude] are the coordinates you want to navigate to. Can be null
  ///
  /// If [address], [latitude] and [longitude] are all null, throw an [Exception]
  /// [address] will prevail over the coordinates if both exist
  ///
  /// Will throw a [NavigationException] if the navigation to an app can not be launch
  /// Will throw an [Exception] if no navigation application is available
  ///
  void showNavigationModal(
    BuildContext context, {
    GpsNavigationOptions options,
    String address,
    double latitude,
    double longitude,
  }) async {
    if (options == null) options = GpsNavigationOptions();

    if (!_navigationValuesValid(address, latitude, longitude)) {
      throw Exception("Address or coordinates must exist");
    }

    // Get the navigation map children
    final List<NavigationMap> children = await _getNavigationChildren();

    // Throw an exception if no navigation application is available
    if (children.isEmpty) {
      throw Exception("No navigation application available");
    }

    // If there's only one navigation application and that the user chose to open automatically, execute the action
    if (children.length == 1 && options.openIfSingleNavigationApp ?? true) {
      children.first.action(
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      return;
    }

    // Open the modal once all the verifications are done
    _openModal(
      context,
      children,
      address,
      latitude,
      longitude,
      options ?? new GpsNavigationOptions(),
    );
  }

  ///
  ///
  /// Private methods
  ///
  ///

  ///
  /// Open the modal bottom sheet
  ///
  void _openModal(
    BuildContext context,
    List<NavigationMap> children,
    String address,
    double latitude,
    double longitude,
    GpsNavigationOptions options,
  ) {
    // Check if the values provided are valid
    Color _backgroundColor = options.backgroundColor ?? Colors.white;

    double _radius = 6.0;
    if (options.borderRadius != null && options.borderRadius >= 0) {
      _radius = options.borderRadius;
    }

    double _height = 56.0;
    if (options.itemHeight != null && options.itemHeight >= 20.0) {
      _height = options.itemHeight;
    }

    Color _titleColor = options.itemTitleColor ?? Colors.black;

    // Show the modal sheet
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
        ),
      ),
      backgroundColor: _backgroundColor,
      builder: (_) {
        return SafeArea(
          child: Container(
            height: children.length * _height,
            child: Column(
              children: children.map(
                ((map) {
                  return SizedBox(
                    height: _height,
                    child: ListTile(
                      title: Center(
                        child: Text(
                          map.name,
                          style: TextStyle(color: _titleColor),
                        ),
                      ),
                      onTap: () {
                        // Close the modal bottom sheet
                        Navigator.of(context).pop();

                        // Wait a bit for the modal to close and execute the action
                        Future.delayed(Duration(milliseconds: 300), () {
                          map.action(
                            address: address,
                            latitude: latitude,
                            longitude: longitude,
                          );
                        });
                      },
                    ),
                  );
                }),
              ).toList(),
            ),
          ),
        );
      },
    );
  }

  ///
  /// Return true if the values are valid, false otherwise
  ///
  /// The values are valid if the address is not null and not empty, or if the latitude and longitude are not null
  ///
  bool _navigationValuesValid(
    String address,
    double latitude,
    double longitude,
  ) {
    final bool addressNotValid = address == null || address.isEmpty;
    if (addressNotValid == null && latitude == null && longitude == null) {
      return false;
    } else {
      return true;
    }
  }

  ///
  /// Return the list of children that will be display inside the modal sheet
  ///
  Future<List<NavigationMap>> _getNavigationChildren() async {
    var children = List<NavigationMap>();

    // If Google Maps exist, add the option into the list
    if (await GoogleMaps().exist()) {
      children.add(new GoogleMaps());
    }

    // If Waze exist, add the option into the list
    if (await Waze().exist()) {
      children.add(new Waze());
    }

    // If we're on an iOS device and that Plans exist, add the option into the list
    if (Platform.isIOS) {
      if (await Plans().exist()) {
        children.add(new Plans());
      }
    }

    // Return the list
    return children;
  }
}
