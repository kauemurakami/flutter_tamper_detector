package com.deebx.flutter_tamper_detector

import java.io.File
import java.net.InetSocketAddress
import java.net.Socket

/** Result of the process instrumentation heuristics, separated by signal strength. */
data class HookInspection(
    val processIndicatorDetected: Boolean,
    val knownPortOpen: Boolean,
    val processInspectionSupported: Boolean
)

/** Collects independent, best-effort runtime instrumentation indicators. */
object HookDetector {
    private val indicators = listOf(
        "frida", "frida-agent", "frida-gadget", "gum-js-loop", "gmain",
        "xposed", "lsposed", "edxposed", "substrate", "substitute",
        "shadowhook", "libhooker", "zygisk", "riru"
    )

    /** Inspects current-process maps/threads and separately checks common Frida ports. */
    fun inspect(): HookInspection {
        val maps = checkProcessMaps()
        val threads = checkThreadNames()
        val processIndicator = maps.first || threads.first || checkKnownPaths()
        return HookInspection(
            processIndicatorDetected = processIndicator,
            knownPortOpen = checkFridaPorts(),
            processInspectionSupported = maps.second || threads.second
        )
    }

    /** Returns true only for process-level indicators, not a port match by itself. */
    fun check(): Boolean = inspect().processIndicatorDetected

    private fun checkProcessMaps(): Pair<Boolean, Boolean> {
        return try {
            val file = File("/proc/self/maps")
            if (!file.canRead()) {
                false to false
            } else {
                val detected = file.useLines { lines ->
                    lines.any { line -> indicators.any { token -> line.contains(token, ignoreCase = true) } }
                }
                detected to true
            }
        } catch (_: Exception) {
            false to false
        }
    }

    private fun checkThreadNames(): Pair<Boolean, Boolean> {
        return try {
            val tasks = File("/proc/self/task").listFiles()
            if (tasks == null) {
                false to false
            } else {
                val detected = tasks.any { task ->
                    val name = File(task, "comm").takeIf { it.canRead() }?.readText()?.trim().orEmpty()
                    indicators.any { token -> name.contains(token, ignoreCase = true) }
                }
                detected to true
            }
        } catch (_: Exception) {
            false to false
        }
    }

    private fun checkKnownPaths(): Boolean {
        val paths = listOf(
            "/data/local/tmp/frida-server", "/data/local/tmp/re.frida.server",
            "/system/bin/frida-server", "/system/xbin/frida-server"
        )
        return paths.any { File(it).exists() }
    }

    /** A listening service on these common ports is a weak signal, not proof of Frida. */
    private fun checkFridaPorts(): Boolean = listOf(27042, 27043).any { port ->
        try {
            Socket().use { socket ->
                socket.connect(InetSocketAddress("127.0.0.1", port), 120)
                true
            }
        } catch (_: Exception) { false }
    }
}
