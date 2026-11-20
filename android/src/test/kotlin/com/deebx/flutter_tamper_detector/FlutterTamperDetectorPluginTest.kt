package com.deebx.flutter_tamper_detector

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.jupiter.api.Test
import org.mockito.Mockito

/** Verifies safe dispatch behavior that does not require a device or Android services. */
internal class FlutterTamperDetectorPluginTest {
    @Test
    fun unknownMethodReturnsNotImplemented() {
        val plugin = FlutterTamperDetectorPlugin()
        val result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(MethodCall("unknown_method", null), result)

        Mockito.verify(result).notImplemented()
    }
}
