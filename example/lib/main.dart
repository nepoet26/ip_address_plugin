import 'package:flutter/material.dart';
import 'package:ip_address_plugin/ip_address_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP Address Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _ipv4;
  String? _ipv6;
  IpNetwork _network = IpNetwork.wifi;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    _getIps();
  }

  Future<void> _getIps() async {
    final ipv4 = await IpAddressPlugin.getIPv4ForNetwork(_network);
    final ipv6 = await IpAddressPlugin.getIPv6ForNetwork(_network);

    setState(() {
      if (ipv4 == null && ipv6 == null) {
        _noInternet = true;
        _ipv4 = null;
        _ipv6 = null;
      } else {
        _noInternet = false;
        _ipv4 = ipv4 ?? 'Không có IPv4';
        _ipv6 = ipv6 ?? 'Không có IPv6';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lấy IP Address')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<IpNetwork>(
              value: _network,
              items: const [
                DropdownMenuItem(value: IpNetwork.wifi, child: Text('Wi‑Fi')),
                DropdownMenuItem(value: IpNetwork.mobile, child: Text('Mobile')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _network = v);
                IpAddressPlugin.clearCache();
                _getIps();
              },
            ),
            const SizedBox(height: 24),
            if (_noInternet)
              const Text('No internet connection', style: TextStyle(fontSize: 20))
            else ...[
              Text('IPv4: $_ipv4', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Text('IPv6: $_ipv6', style: const TextStyle(fontSize: 20)),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _getIps,
              child: const Text('Lấy lại IP'),
            ),
          ],
        ),
      ),
    );
  }
}