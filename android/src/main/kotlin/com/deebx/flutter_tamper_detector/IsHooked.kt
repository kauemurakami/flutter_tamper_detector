package com.deebx.flutter_tamper_detector

import java.io.File

object HookDetector {
    fun check(): Boolean {
        return isFridaPresent() || isShadowPresent() || isXposedPresent() || isSubstratePresent() || isFreedaPresent()
    }

    private fun isFridaPresent(): Boolean {
        val paths = arrayOf(
            "/data/local/tmp/frida-server",
            "/system/bin/frida-server",
            "/system/xbin/frida-server",
            "/data/local/tmp/re.frida.server"
        )
        return paths.any { File(it).exists() }
    }

    private fun isShadowPresent(): Boolean {
        val hookingLibs = arrayOf("libshadowhook.so", "libshadow.so")
        return checkForLibraries(hookingLibs)
    }

    private fun isXposedPresent(): Boolean {
        val hookingLibs = arrayOf("libxposed.so", "libedxposed.so")
        return checkForLibraries(hookingLibs)
    }

    private fun isSubstratePresent(): Boolean {
        val hookingLibs = arrayOf("libsubstrate.so", "libsubstrate-dvm.so")
        return checkForLibraries(hookingLibs)
    }

    private fun isFreedaPresent(): Boolean {
        val paths = arrayOf(
            "/data/local/tmp/freeda-server",
            "/system/bin/freeda-server",
            "/system/xbin/freeda-server"
        )
        return paths.any { File(it).exists() }
    }

    private fun checkForLibraries(libs: Array<String>): Boolean {
        return libs.any { lib ->
            File("/system/lib/$lib").exists() || File("/system/lib64/$lib").exists()
        }
    }
}
