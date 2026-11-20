package com.deebx.flutter_tamper_detector

/** Checks system-build and verified-boot properties independently of root access. */
object SystemPropsChecker {
    /** Returns true for test build tags, debuggable system images, or unlocked boot state. */
    fun isModifiedSystem(): Boolean {
        val tags = ShellExecutor.getSystemProperty("ro.build.tags").orEmpty()
        val debuggable = ShellExecutor.getSystemProperty("ro.debuggable").orEmpty()
        val secure = ShellExecutor.getSystemProperty("ro.secure").orEmpty()
        val verifiedBoot = ShellExecutor.getSystemProperty("ro.boot.verifiedbootstate").orEmpty()
        val flashLocked = ShellExecutor.getSystemProperty("ro.boot.flash.locked").orEmpty()
        return tags.contains("test-keys", ignoreCase = true) || debuggable == "1" || secure == "0" ||
            verifiedBoot.equals("orange", true) || verifiedBoot.equals("yellow", true) || flashLocked == "0"
    }
}
