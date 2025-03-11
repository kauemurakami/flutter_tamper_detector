package com.deebx.flutter_tamper_detector

class RootChecker {
    companion object {
        // Função que retorna se o dispositivo está rooteado
        fun isDeviceRooted(): Boolean {
            return isRooted()
        }

        // Função privada que verifica se o dispositivo está rooteado
        private fun isRooted(): Boolean {
            return RootFilesChecker.checkSuFiles() ||
                   RootCommandsChecker.checkCommands() ||
                   SystemPropsChecker.checkSystemProps()
        }
    }
}
