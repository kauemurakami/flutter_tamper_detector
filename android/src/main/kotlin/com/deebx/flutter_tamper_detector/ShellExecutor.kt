package com.deebx.flutter_tamper_detector

import java.io.BufferedReader
import java.io.InputStreamReader

object ShellExecutor {
    fun executeCommand(command: String): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(command)
            val input = BufferedReader(InputStreamReader(process.inputStream))
            input.readLine() != null
        } catch (e: Exception) {
            false
        }
    }

    fun getSystemProperty(prop: String): String? {
        return try {
            val process = Runtime.getRuntime().exec("getprop $prop")
            val input = BufferedReader(InputStreamReader(process.inputStream))
            input.readLine()
        } catch (e: Exception) {
            null
        }
    }
}
