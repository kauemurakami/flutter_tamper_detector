package com.deebx.flutter_tamper_detector

object SystemPropsChecker {
    fun checkSystemProps(): Boolean {
        val properties = arrayOf(
            "ro.build.tags",        // "test-keys" indica root
            "ro.debuggable",        // "1" indica root
            "ro.secure",            // "0" indica root
            "ro.bootmode",          // "recovery" ou "fastboot" pode indicar root
            "ro.boot.verifiedbootstate" // "orange" ou "yellow" indica root
        )

        for (prop in properties) {
            val value = ShellExecutor.getSystemProperty(prop)
            if (value != null) {
                if (prop == "ro.build.tags" && value.contains("test-keys")) return true
                if (prop == "ro.debuggable" && value == "1") return true
                if (prop == "ro.secure" && value == "0") return true
                if (prop == "ro.bootmode" && (value == "recovery" || value == "fastboot")) return true
                if (prop == "ro.boot.verifiedbootstate" && (value == "orange" || value == "yellow")) return true
            }
        }
        return false
    }
}
