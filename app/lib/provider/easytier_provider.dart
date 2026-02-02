import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:common/model/device.dart';
import 'package:flutter/foundation.dart';
import 'package:localsend_app/model/state/settings_state.dart';
import 'package:localsend_app/rust/api/easytier.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:rxdart/rxdart.dart';

class EasyTierService extends Notifier {
  bool _isRunning = false;
  List<Device> _networkMembers = [];
  Timer? _networkPollTimer;

  bool get isRunning => _isRunning;

  final BehaviorSubject<List<Device>> _networkMembersSubject =
      BehaviorSubject.seeded(<Device>[]);

  Stream<List<Device>> get networkMembersStream => _networkMembersSubject.stream;

  @override
  void dispose() {
    _networkPollTimer?.cancel();
    _networkMembersSubject.close();
    super.dispose();
  }

  Future<bool> startEasyTier(SettingsState settings) async {
    if (!settings.enableEasyTier) {
      return false;
    }

    try {
      // Start the actual EasyTier network using Rust bridge
      final success = await EasytierApi.easytier_start_network(
        settings.easyTierNetworkName,
        settings.easyTierNetworkSecret,
        settings.easyTierPublicServerUrl,
      );

      if (success) {
        _isRunning = true;

        // Simulate polling for network members (in a real implementation,
        // this would come from actual EasyTier network events)
        _startNetworkPolling(settings);
      }

      return success;
    } catch (e) {
      debugPrint('Failed to start EasyTier: $e');
      return false;
    }
  }

  Future<void> stopEasyTier() async {
    if (_isRunning) {
      await EasytierApi.easytier_stop_network();
      _isRunning = false;
      _networkPollTimer?.cancel();
    }
  }

  void _startNetworkPolling(SettingsState settings) {
    _networkPollTimer?.cancel();

    // Poll every 5 seconds for network members
    _networkPollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_isRunning) {
        _refreshNetworkMembers(settings);
      }
    });

    // Initial refresh
    _refreshNetworkMembers(settings);
  }

  void _refreshNetworkMembers(SettingsState settings) {
    if (!settings.enableEasyTier) {
      _networkMembers = [];
      _networkMembersSubject.add(_networkMembers);
      return;
    }

    // In a real implementation, this would fetch actual network members from EasyTier
    // For now, we'll simulate some network members
    final simulatedMembers = <Device>[
      // Add the current device
      Device(
        ip: '10.144.144.1', // Simulated EasyTier IP
        port: settings.port,
        deviceId: 'easytier-${settings.alias}-current',
        deviceName: '${settings.alias} (via EasyTier)',
        deviceModel: settings.deviceModel ?? 'Unknown',
        deviceType: settings.deviceType ?? DeviceType.desktop,
        version: '1.0.0',
        https: settings.https,
      ),
    ];

    // Add some simulated other members if network is active
    if (settings.easyTierNetworkName.isNotEmpty) {
      simulatedMembers.addAll([
        Device(
          ip: '10.144.144.2',
          port: settings.port,
          deviceId: 'easytier-device-1',
          deviceName: 'Another Device (via EasyTier)',
          deviceModel: 'Simulated Device',
          deviceType: DeviceType.phone,
          version: '1.0.0',
          https: settings.https,
        ),
        Device(
          ip: '10.144.144.3',
          port: settings.port,
          deviceId: 'easytier-device-2',
          deviceName: 'Third Device (via EasyTier)',
          deviceModel: 'Simulated Laptop',
          deviceType: DeviceType.laptop,
          version: '1.0.0',
          https: settings.https,
        ),
      ]);
    }

    _networkMembers = simulatedMembers;
    _networkMembersSubject.add(_networkMembers);
  }

  // Method to get current network members
  List<Device> getCurrentNetworkMembers() {
    return List.from(_networkMembers);
  }
}

final easyTierServiceProvider = NotifierProvider<EasyTierService, void>((ref) {
  return EasyTierService();
});