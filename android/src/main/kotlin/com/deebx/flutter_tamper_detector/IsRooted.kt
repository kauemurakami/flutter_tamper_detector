package com.deebx.flutter_tamper_detector

class RootChecker {
    companion object {

        fun isDeviceRooted(): Boolean {
            return isRooted()
        }

        private fun isRooted(): Boolean {
            return RootFilesChecker.checkSuFiles() ||
                   RootCommandsChecker.checkCommands() ||
                   SystemPropsChecker.checkSystemProps()
        }
    }
}
