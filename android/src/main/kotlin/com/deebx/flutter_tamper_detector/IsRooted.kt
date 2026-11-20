package com.deebx.flutter_tamper_detector

/** Root heuristics kept separate from modified-ROM and verified-boot signals. */
object RootChecker {
    /** Returns true when common root binaries, managers, or executable commands are observable. */
    fun isDeviceRooted(): Boolean = RootFilesChecker.checkSuFiles() || RootCommandsChecker.checkCommands()
}
