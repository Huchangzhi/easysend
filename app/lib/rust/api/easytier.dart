// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
// ignore_for_file: unused_import
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:localsend_app/rust/frb_generated.dart';
import 'package:localsend_app/rust/frb_generated.io.dart'
    if (dart.library.js_interop) 'frb_generated.web.dart';

/// API functions for easytier module
class EasytierApi {
  /// Starts the EasyTier network with the given configuration
  static Future<bool> easytier_start_network(
    String network_name,
    String network_secret,
    String public_server_url,
  ) async {
    return await RustLib.instance.api!.easytier_start_network(
      network_name,
      network_secret,
      public_server_url,
    );
  }

  /// Stops the EasyTier network
  static Future<bool> easytier_stop_network() async {
    return await RustLib.instance.api!.easytier_stop_network();
  }

  /// Checks if the EasyTier network is currently running
  static bool easytier_is_running() {
    return RustLib.instance.api!.easytier_is_running();
  }
}