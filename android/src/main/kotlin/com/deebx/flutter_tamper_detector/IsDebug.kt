package com.deebx.flutter_tamper_detector

import android.content.Context
import android.content.pm.ApplicationInfo

object IsDebug {
    fun check(context: Context): Boolean {
        return context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
    }
}
