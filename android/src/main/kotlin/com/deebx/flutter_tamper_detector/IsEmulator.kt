package com.deebx.flutter_tamper_detector

import android.os.Build

object IsEmulator {
    fun check(): Boolean {
        val buildProps = listOf(
            Build.FINGERPRINT.startsWith("generic"),
            Build.MODEL.contains("google_sdk"),
            Build.MODEL.contains("Emulator"),
            Build.MODEL.contains("Android SDK built for x86"),
            Build.MANUFACTURER.contains("Genymotion"),
            Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"),
            "google_sdk" == Build.PRODUCT,
            Build.HARDWARE.contains("goldfish") || Build.HARDWARE.contains("ranchu"),
            Build.PRODUCT.contains("sdk_google"),
            Build.PRODUCT.contains("sdk"),
            Build.PRODUCT.contains("sdk_x86"),
            Build.PRODUCT.contains("sdk_gphone"),
            Build.PRODUCT.contains("vbox86p"),
            Build.BOARD.contains("unknown")
        )
        return buildProps.contains(true)
    }
}
