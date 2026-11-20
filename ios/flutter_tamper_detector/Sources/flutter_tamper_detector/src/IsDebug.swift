import Foundation
import Darwin

/// Detects a native debugger attached to the current iOS process.
enum IsDebug {
    /// Indicates whether runtime debugger inspection is supported on this target.
    static var isSupported: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    /// Returns true when the kernel marks the process as traced.
    static func isDebuggerAttached() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        var processInfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.size
        let result = sysctl(&mib, u_int(mib.count), &processInfo, &size, nil, 0)
        guard result == 0 else { return false }
        return (processInfo.kp_proc.p_flag & P_TRACED) != 0
        #endif
    }
}
