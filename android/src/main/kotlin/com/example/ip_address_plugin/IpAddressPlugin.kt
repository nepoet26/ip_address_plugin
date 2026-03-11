package com.example.ip_address_plugin

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.NetworkInterface
import java.util.*

class IpAddressPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var appContext: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ip_address_plugin")  // ← đổi channel
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getIPv4" -> result.success(getIpAddress(useIPv4 = true))
            "getIPv6" -> result.success(getIpAddress(useIPv4 = false))
            "getIPv4ForNetwork" -> {
                val type = call.argument<String>("type") ?: "wifi"
                result.success(getIpAddressForNetwork(useIPv4 = true, type = type))
            }
            "getIPv6ForNetwork" -> {
                val type = call.argument<String>("type") ?: "wifi"
                result.success(getIpAddressForNetwork(useIPv4 = false, type = type))
            }
            else -> result.notImplemented()
        }
    }

    private fun getIpAddressForNetwork(useIPv4: Boolean, type: String): String? {
        val normalized = type.lowercase(Locale.ROOT)
        val expected = when (normalized) {
            "wifi", "mobile" -> normalized
            "any" -> "wifi"
            else -> "wifi"
        }

        val cm = appContext.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return null

        val networks = cm.allNetworks ?: return null
        for (network in networks) {
            val caps = cm.getNetworkCapabilities(network) ?: continue
            val matches = when (expected) {
                "wifi" -> caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                "mobile" -> caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                else -> false
            }
            if (!matches) continue

            val linkProperties = cm.getLinkProperties(network) ?: continue
            for (linkAddress in linkProperties.linkAddresses) {
                val addr = linkAddress.address ?: continue
                if (addr.isLoopbackAddress) continue

                val ip = addr.hostAddress?.trim() ?: continue
                if (useIPv4) {
                    if (addr is Inet4Address && !ip.startsWith("127.") && !ip.startsWith("169.254.")) {
                        return ip
                    }
                } else {
                    if (addr is Inet6Address &&
                        !ip.startsWith("fe80:", ignoreCase = true) &&
                        !ip.startsWith("::1") &&
                        !ip.startsWith("fc", ignoreCase = true) &&
                        !ip.startsWith("fd", ignoreCase = true)
                    ) {
                        return ip
                    }
                }
            }
        }
        return null
    }

    private fun getIpAddress(useIPv4: Boolean): String? {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            if (interfaces == null) {
                println("No network interfaces found")
                return null
            }

            val allInterfaces = Collections.list(interfaces)

            // Log để debug (xem console Android Studio / logcat)
            allInterfaces.forEach { intf ->
                println("Interface: ${intf.name} - up: ${intf.isUp} - loopback: ${intf.isLoopback}")
                val addrs = Collections.list(intf.inetAddresses)
                addrs.forEach { addr ->
                    println("  IP: ${addr.hostAddress} - isLoopback: ${addr.isLoopbackAddress} - IPv4: ${addr is java.net.Inet4Address}")
                }
            }

            for (intf in allInterfaces) {
                if (!intf.isUp || intf.isLoopback) continue  // Bỏ interface down hoặc loopback

                val addrs = Collections.list(intf.inetAddresses)
                for (addr in addrs) {
                    if (addr.isLoopbackAddress) continue

                    val ip = addr.hostAddress?.trim() ?: continue

                    if (useIPv4) {
                        if (addr is Inet4Address && !ip.startsWith("127.") && !ip.startsWith("169.254.")) {
                            return ip  // Trả về IPv4 đầu tiên hợp lệ (thường là WiFi/local)
                        }
                    } else {
                        if (addr is Inet6Address &&
                            !ip.startsWith("fe80:", ignoreCase = true) &&
                            !ip.startsWith("::1") &&
                            !ip.startsWith("fc", ignoreCase = true) &&
                            !ip.startsWith("fd", ignoreCase = true)
                        ) {
                            return ip  // IPv6 global/ULA
                        }
                    }
                }
            }
            println("No valid IP found for family ${if (useIPv4) "IPv4" else "IPv6"}")
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}