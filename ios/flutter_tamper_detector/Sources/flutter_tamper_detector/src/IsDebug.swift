// Sources/flutter_tamper_detector/src/IsDebug.swift
import Foundation

class IsDebug {
    static func check() -> Bool {
        // If the application was compiled under the local Debug scheme (e.g., flutter run),
        // always return true to facilitate local development and catch toolchains.
        #if DEBUG
        return true
        #else
        
        // Low-level production kernel check to detect if a native debugger (like LLDB) is attached
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.size
        
        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        
        if result == 0 {
            // Check if the P_TRACED flag is set in the process flags mask
            return (info.kp_proc.p_flag & P_TRACED) != 0
        }
        
        return false // Safe fallback if the system call fails
        #endif
    }
}