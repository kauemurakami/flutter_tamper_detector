package com.deebx.flutter_tamper_detector

import android.app.Activity
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

object AppPrivacy {

    fun setAppPrivacy(activity: Activity, preventScreenshot: Boolean, hideInMenu: Boolean) {
        activity.window?.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        activity.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)


        if (preventScreenshot) {
            activity.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } 

        if (hideInMenu) {
            activity.window?.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        } 


    }
}