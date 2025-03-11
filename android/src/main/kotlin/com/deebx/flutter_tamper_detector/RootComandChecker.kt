package com.deebx.flutter_tamper_detector

object RootCommandsChecker {
    fun checkCommands(): Boolean {
        val commands = arrayOf(
            "which su",
            "which magisk",
            "which busybox",
            "which daemonsu"
        )

        return commands.any { ShellExecutor.executeCommand(it) }
    }
}
