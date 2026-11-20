package com.deebx.flutter_tamper_detector

import android.app.Activity
import android.view.WindowManager

/** Applies Android window flags for screenshot and recent-task privacy. */
object AppPrivacy {
    /**
     * Enables FLAG_SECURE when either capture protection or task-preview privacy is requested.
     * Android does not expose a supported API to remove an app from the Recents list.
     */
    fun configure(activity: Activity, preventScreenshot: Boolean, hideInMenu: Boolean) {
        val secure = preventScreenshot || hideInMenu
        if (secure) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
