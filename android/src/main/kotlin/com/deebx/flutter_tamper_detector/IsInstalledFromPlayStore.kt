package com.deebx.flutter_tamper_detector

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.ApplicationInfo

object IsInstalledFromPlayStore {
    fun check(context: Context): Boolean {
        return try {
            val packageManager: PackageManager = context.packageManager
            val packageName = context.packageName
            val installerPackageName = packageManager.getInstallerPackageName(packageName)

            // Check if the package was installed from the Play Store
            installerPackageName != null && installerPackageName == "com.android.vending"
        } catch (e: Exception) {
            false
        }
    }
}