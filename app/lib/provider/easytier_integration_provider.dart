import 'dart:async';
import 'package:common/model/device.dart';
import 'package:localsend_app/model/state/settings_state.dart';
import 'package:localsend_app/provider/easytier_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// Service that integrates EasyTier network with LocalSend's device discovery
class EasyTierIntegrationService extends Notifier {
  late EasyTierService _easyTierService;
  StreamSubscription<List<Device>>? _networkMembersSubscription;

  @override
  void initState() {
    super.initState();
    _easyTierService = ref.read(easyTierServiceProvider.notifier);
  }

  /// Starts EasyTier integration based on settings
  Future<void> startIntegration(SettingsState settings) async {
    // Stop any existing integration
    await stopIntegration();

    // Start EasyTier if enabled in settings
    if (settings.enableEasyTier) {
      await _easyTierService.startEasyTier(settings);

      // Subscribe to network members updates
      _networkMembersSubscription = _easyTierService.networkMembersStream.listen(
        _onNetworkMembersUpdate,
      );
    }
  }

  /// Stops EasyTier integration
  Future<void> stopIntegration() async {
    _networkMembersSubscription?.cancel();
    await _easyTierService.stopEasyTier();
  }

  /// Callback when network members update
  void _onNetworkMembersUpdate(List<Device> members) {
    // Dispatch the devices to the nearby devices provider
    ref.redux(nearbyDevicesProvider).dispatch(RegisterEasyTierDevicesAction(members));

    if (kDebugMode) {
      print('EasyTier network members updated: ${members.length} devices');
      for (final device in members) {
        print('  - ${device.deviceName} at ${device.ip}');
      }
    }
  }

  /// Gets the current EasyTier network members
  List<Device> getCurrentNetworkMembers() {
    return _easyTierService.getCurrentNetworkMembers();
  }

  @override
  void dispose() {
    _networkMembersSubscription?.cancel();
    super.dispose();
  }
}

final easyTierIntegrationProvider =
    NotifierProvider<EasyTierIntegrationService, void>((ref) {
  return EasyTierIntegrationService();
});