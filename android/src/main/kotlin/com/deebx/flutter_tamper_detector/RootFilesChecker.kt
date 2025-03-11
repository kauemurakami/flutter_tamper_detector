package com.deebx.flutter_tamper_detector

import java.io.File

object RootFilesChecker {
    fun checkSuFiles(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/system/xbin/su",
            "/system/bin/su",
            "/system/bin/.ext/.su",
            "/system/sd/xbin/su",
            "/sbin/su",
            "/system/etc/init.d/99SuperSUDaemon",
            "/system/xbin/daemonsu",
            "/system/bin/.ext/.su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/su",
            "/system/bin/magisk",
            "/sbin/magisk",
            "/data/local/tmp/magisk",
            "/system/bin/magiskhide",
            "/sbin/magiskhide",
            "/data/local/tmp/magiskhide"
        )

        return paths.any { File(it).exists() }
    }
}
