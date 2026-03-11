import Flutter
import UIKit
import Darwin

public class IpAddressPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ip_address_plugin",
      binaryMessenger: registrar.messenger()
    )
    let instance = IpAddressPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getIPv4":
      // Mặc định ưu tiên Wi‑Fi
      result(getIPAddress(forFamily: AF_INET, networkType: "wifi"))
    case "getIPv6":
      // Mặc định ưu tiên Wi‑Fi
      result(getIPAddress(forFamily: AF_INET6, networkType: "wifi"))
    case "getIPv4ForNetwork":
      let type = (call.arguments as? [String: Any])?["type"] as? String
      result(getIPAddress(forFamily: AF_INET, networkType: type))
    case "getIPv6ForNetwork":
      let type = (call.arguments as? [String: Any])?["type"] as? String
      result(getIPAddress(forFamily: AF_INET6, networkType: type))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getIPAddress(forFamily family: Int32, networkType: String?) -> String? {
    let normalized = (networkType ?? "wifi").lowercased()
    let expected: String = {
      switch normalized {
      case "wifi", "mobile":
        return normalized
      case "any":
        return "wifi"
      default:
        return "wifi"
      }
    }()

    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    defer { freeifaddrs(ifaddr) }

    var ptr = ifaddr
    while ptr != nil {
      let flags = Int32(ptr!.pointee.ifa_flags)
      let addr = ptr!.pointee.ifa_addr.pointee

      // Chỉ lấy interface UP + RUNNING, không phải loopback
      if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) &&
         addr.sa_family == UInt8(family) {

        let interfaceName = String(cString: ptr!.pointee.ifa_name)

        let matchesNetwork: Bool = {
          switch expected {
          case "wifi":
            return interfaceName.hasPrefix("en") // en0 thường là Wi‑Fi
          case "mobile":
            return interfaceName.hasPrefix("pdp_ip") // pdp_ip0 thường là Cellular
          default:
            return false
          }
        }()

        if matchesNetwork {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(
            ptr!.pointee.ifa_addr,
            socklen_t(addr.sa_len),
            &hostname,
            socklen_t(NI_MAXHOST),
            nil,
            socklen_t(0),
            NI_NUMERICHOST
          )

          let ip = String(cString: hostname)

          if family == AF_INET {
            if ip.hasPrefix("127.") || ip.hasPrefix("169.254.") {
              ptr = ptr!.pointee.ifa_next
              continue
            }
          } else if family == AF_INET6 {
            let lower = ip.lowercased()
            if lower.hasPrefix("fe80:") || lower == "::1" || lower.hasPrefix("fc") || lower.hasPrefix("fd") {
              ptr = ptr!.pointee.ifa_next
              continue
            }
          }
          return ip
        }
      }
      ptr = ptr!.pointee.ifa_next
    }
    return nil
  }
}