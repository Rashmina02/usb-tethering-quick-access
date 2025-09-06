package com.example.usbtethering

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        openPortableHotspotSettings()
    }

    private fun openPortableHotspotSettings() {
        try {
            // Method 1: Direct intent for Portable Hotspot (Xiaomi specific)
            val hotspotIntent = Intent().apply {
                action = "android.settings.WIFI_HOTSPOT_SETTINGS"
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            startActivity(hotspotIntent)
            
        } catch (e: Exception) {
            try {
                // Method 2: Alternative hotspot intent
                val tetherIntent = Intent().apply {
                    action = "android.settings.TETHER_SETTINGS"
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    putExtra(":android:show_fragment", "WifiTetherSettings")
                }
                startActivity(tetherIntent)
                
            } catch (e2: Exception) {
                try {
                    // Method 3: General wireless settings as fallback
                    val wirelessIntent = Intent(Settings.ACTION_WIRELESS_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }
                    startActivity(wirelessIntent)
                    
                } catch (e3: Exception) {
                    // Final fallback: General settings
                    val settingsIntent = Intent(Settings.ACTION_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }
                    startActivity(settingsIntent)
                }
            }
        }
        
        // NUCLEAR OPTION - This will definitely close the app
        android.os.Process.killProcess(android.os.Process.myPid())
    }
}