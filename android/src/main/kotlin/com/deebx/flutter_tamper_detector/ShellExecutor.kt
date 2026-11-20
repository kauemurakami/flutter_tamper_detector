package com.deebx.flutter_tamper_detector

import java.io.File
import java.util.concurrent.TimeUnit

/** Executes narrowly scoped, unprivileged system-property and PATH checks. */
object ShellExecutor {
    /** Returns true when [binary] can be resolved in a standard executable directory. */
    fun commandExists(binary: String): Boolean {
        val directories = listOf("/system/bin", "/system/xbin", "/vendor/bin", "/sbin")
        return directories.any { directory -> File(directory, binary).canExecute() }
    }

    /** Reads a single Android system property without invoking a shell interpreter. */
    fun getSystemProperty(property: String): String? {
        if (!property.matches(Regex("[a-zA-Z0-9._]+"))) return null
        return try {
            val process = ProcessBuilder("getprop", property).redirectErrorStream(true).start()
            if (!process.waitFor(300, TimeUnit.MILLISECONDS)) {
                process.destroyForcibly()
                null
            } else {
                process.inputStream.bufferedReader().use { it.readLine()?.trim() }
            }
        } catch (_: Exception) {
            null
        }
    }
}
