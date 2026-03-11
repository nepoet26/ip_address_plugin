import 'package:flutter/services.dart';

enum IpNetwork {
  wifi,
  mobile,
}

class IpAddressPlugin {
  static const MethodChannel _channel = MethodChannel('ip_address_plugin');

  // Cache theo "family + network"
  static final Map<String, String> _cached = <String, String>{};
  static final Map<String, DateTime> _lastFetchTime = <String, DateTime>{};
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Kiểm tra cache còn hợp lệ không
  static bool _isCacheValid(String key) {
    final ts = _lastFetchTime[key];
    if (ts == null) return false;
    return DateTime.now().difference(ts) < _cacheDuration;
  }

  /// Lấy IPv4 (có cache)
  static Future<String?> getIPv4({bool forceRefresh = false}) async {
    return getIPv4ForNetwork(IpNetwork.wifi, forceRefresh: forceRefresh);
  }

  /// Lấy IPv4 theo loại mạng (wifi/mobile)
  static Future<String?> getIPv4ForNetwork(
    IpNetwork network, {
    bool forceRefresh = false,
  }) async {
    final key = 'ipv4:${network.name}';
    final cached = _cached[key];
    if (!forceRefresh && cached != null && _isCacheValid(key)) {
      return cached;
    }

    try {
      final String? ip = await _channel.invokeMethod(
        'getIPv4ForNetwork',
        <String, dynamic>{'type': network.name},
      );
      if (ip != null && ip.isNotEmpty) {
        _cached[key] = ip;
        _lastFetchTime[key] = DateTime.now();
      }
      return ip;
    } catch (e) {
      return cached; // fallback về cache cũ nếu lỗi
    }
  }

  /// Lấy IPv6 (có cache)
  static Future<String?> getIPv6({bool forceRefresh = false}) async {
    return getIPv6ForNetwork(IpNetwork.wifi, forceRefresh: forceRefresh);
  }

  /// Lấy IPv6 theo loại mạng (wifi/mobile)
  static Future<String?> getIPv6ForNetwork(
    IpNetwork network, {
    bool forceRefresh = false,
  }) async {
    final key = 'ipv6:${network.name}';
    final cached = _cached[key];
    if (!forceRefresh && cached != null && _isCacheValid(key)) {
      return cached;
    }

    try {
      final String? ip = await _channel.invokeMethod(
        'getIPv6ForNetwork',
        <String, dynamic>{'type': network.name},
      );
      if (ip != null && ip.isNotEmpty) {
        _cached[key] = ip;
        _lastFetchTime[key] = DateTime.now();
      }
      return ip;
    } catch (e) {
      return cached;
    }
  }

  /// Xóa cache thủ công nếu cần (ví dụ: khi app detect network change)
  static void clearCache() {
    _cached.clear();
    _lastFetchTime.clear();
  }
}