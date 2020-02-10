import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gps_navigation/src/maps/google_maps.dart';
import 'package:gps_navigation/src/maps/plans.dart';
import 'package:gps_navigation/src/maps/waze.dart';

///
/// Class that allow the gps navigation to a destination via a modal sheet
///
class NavigationHelper {
  static final _instance = NavigationHelper._();

  NavigationHelper._();

  ///
  /// Return the static instance of the class
  ///
  factory NavigationHelper() => _instance;

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
  /// - [backgroundColor] represent the background color of the modal sheet
  /// - [borderRadius] represent the top-left and top-right radius of the modal sheet
  /// - [itemHeight] represent the height of each item in the modal sheet
  /// - [itemTitleColor] represent the color of each title of each item of the modal sheet
  /// - [address] is the postal address where you want to navigate to. Can be null
  /// - [latitude] and [longitude] are the coordinates you want to navigate to. Can be null
  ///
  /// If [address], [latitude] and [longitude] are all null, throw an [Exception]
  /// [address] will prevail over the coordinates if both exist
  ///
  /// Can throw a [NavigationException] if the navigation to an app can not be launch
  ///
  void showNavigationModal(
    BuildContext context, {
    Color backgroundColor = Colors.white,
    double borderRadius = 6.0,
    double itemHeight = 56.0,
    Color itemTitleColor = Colors.black,
    String address,
    double latitude,
    double longitude,
  }) async {
    if (address == null && latitude == null && longitude == null) {
      throw Exception("Address or coordinates must exist");
    }

    Color _backgroundColor = backgroundColor ?? Colors.white;
    double _radius =
        (borderRadius == null || borderRadius < 0) ? 6.0 : borderRadius;
    double _height = (itemHeight == null || itemHeight < 0) ? 56.0 : itemHeight;
    Color _titleColor = itemTitleColor ?? Colors.black;

    final children = await _getModalChildren(
      context,
      itemHeight: _height,
      itemTitleColor: _titleColor,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    if (children.isEmpty) return;

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
            child: Column(children: children),
          ),
        );
      },
    );
  }

  ///
  ///
  /// Private methods
  ///
  ///

  ///
  /// Return the list of children that will be display inside the modal sheet
  ///
  Future<List<Widget>> _getModalChildren(
    BuildContext context, {
    double itemHeight,
    Color itemTitleColor,
    String address,
    double latitude,
    double longitude,
  }) async {
    var children = List<Widget>();

    // If the address and the coordinates are not valid, return an empty array
    final bool addressNotValid = address == null || address.isEmpty;
    if (addressNotValid && latitude == null && longitude == null) {
      return children;
    }

    // If Google Maps exist, add the option into the list
    final googleMapsExist = await GoogleMaps().exist();
    if (googleMapsExist) {
      children.add(
        SizedBox(
          height: itemHeight,
          child: ListTile(
              title: Center(
                child: Text(
                  GoogleMaps().name,
                  style: TextStyle(color: itemTitleColor),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 300), () {
                  GoogleMaps().action(
                    address: address,
                    latitude: latitude,
                    longitude: longitude,
                  );
                });
              }),
        ),
      );
    }

    // If Waze exist, add the option into the list
    final wazeExist = await Waze().exist();
    if (wazeExist) {
      children.add(
        SizedBox(
          height: itemHeight,
          child: ListTile(
            title: Center(
              child: Text(
                Waze().name,
                style: TextStyle(color: itemTitleColor),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Future.delayed(Duration(milliseconds: 300), () {
                Waze().action(
                  address: address,
                  latitude: latitude,
                  longitude: longitude,
                );
              });
            },
          ),
        ),
      );
    }

    // If we're on an iOS device and that Plans exist, add the option into the list
    if (Platform.isIOS) {
      final plansExist = await Plans().exist();
      if (plansExist) {
        children.add(
          SizedBox(
            height: itemHeight,
            child: ListTile(
              title: Center(
                child: Text(
                  Plans().name,
                  style: TextStyle(color: itemTitleColor),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 300), () {
                  Plans().action(
                    address: address,
                    latitude: latitude,
                    longitude: longitude,
                  );
                });
              },
            ),
          ),
        );
      }
    }

    // Return the list
    return children;
  }
}
