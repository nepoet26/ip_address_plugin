// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ip_address_plugin/ip_address_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getIPv4ForNetwork does not throw', (WidgetTester tester) async {
    final String? ipv4 = await IpAddressPlugin.getIPv4ForNetwork(IpNetwork.wifi);
    expect(ipv4 == null || ipv4.isNotEmpty, true);
  });
}
