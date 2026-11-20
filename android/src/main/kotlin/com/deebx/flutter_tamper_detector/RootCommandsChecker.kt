package com.deebx.flutter_tamper_detector

/** Looks for commonly exposed root-management executables on the app PATH. */
object RootCommandsChecker {
    /** Returns true when a known root executable can be resolved by the shell environment. */
    fun checkCommands(): Boolean = listOf("su", "magisk", "busybox", "daemonsu").any { command ->
        ShellExecutor.commandExists(command)
    }
}
