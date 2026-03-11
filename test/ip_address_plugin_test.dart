import 'package:flutter_test/flutter_test.dart';
import 'package:ip_address_plugin/ip_address_plugin.dart';
import 'package:ip_address_plugin/ip_address_plugin_platform_interface.dart';
import 'package:ip_address_plugin/ip_address_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIpAddressPluginPlatform
    with MockPlatformInterfaceMixin
    implements IpAddressPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IpAddressPluginPlatform initialPlatform = IpAddressPluginPlatform.instance;

  test('$MethodChannelIpAddressPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIpAddressPlugin>());
  });

  test('getPlatformVersion', () async {
    IpAddressPlugin ipAddressPlugin = IpAddressPlugin();
    MockIpAddressPluginPlatform fakePlatform = MockIpAddressPluginPlatform();
    IpAddressPluginPlatform.instance = fakePlatform;

    expect(await ipAddressPlugin.getPlatformVersion(), '42');
  });
}
