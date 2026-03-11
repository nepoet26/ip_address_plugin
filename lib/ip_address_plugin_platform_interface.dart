import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ip_address_plugin_method_channel.dart';

abstract class IpAddressPluginPlatform extends PlatformInterface {
  /// Constructs a IpAddressPluginPlatform.
  IpAddressPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static IpAddressPluginPlatform _instance = MethodChannelIpAddressPlugin();

  /// The default instance of [IpAddressPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelIpAddressPlugin].
  static IpAddressPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IpAddressPluginPlatform] when
  /// they register themselves.
  static set instance(IpAddressPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
