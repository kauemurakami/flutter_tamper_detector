import Foundation
import MachO

/// Inspects dynamic images already loaded into the current process.
enum IsHooked {
    /// Indicates whether loaded-image inspection is supported on this target.
    static var isSupported: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    private static let indicators = [
        "fridagadget", "frida-agent", "libfrida", "substrate",
        "mobilesubstrate", "substitute", "libhooker", "ellekit",
        "xposed", "shadowhook", "cycript"
    ]

    /// Returns true when a loaded image path contains a known instrumentation marker.
    /// This is heuristic and does not detect every possible inline or symbol hook.
    static func check() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let imageCount = _dyld_image_count()
        for index in 0..<imageCount {
            guard let imageName = _dyld_get_image_name(index) else { continue }
            let path = String(cString: imageName).lowercased()
            if indicators.contains(where: { path.contains($0) }) { return true }
        }
        return false
        #endif
    }
}
