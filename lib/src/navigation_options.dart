import 'package:flutter/material.dart';

///
/// Class that represent the options possible to use to open the modal
///
class GpsNavigationOptions {
  /// Background color of the modal bottom sheet
  final Color backgroundColor;

  /// Top left and right radius of the modal bottom sheet
  final double borderRadius;

  /// Height of each item in the modal bottom sheet
  final double itemHeight;

  /// Color of each item in the modal bottom sheet
  final Color itemTitleColor;

  /// Flag to know if the plugin should open the navigation application if there's only one available on the device
  final bool openIfSingleNavigationApp;

  GpsNavigationOptions({
    this.backgroundColor = Colors.white,
    this.borderRadius = 6.0,
    this.itemHeight = 56.0,
    this.itemTitleColor = Colors.black,
    this.openIfSingleNavigationApp = true,
  });
}
