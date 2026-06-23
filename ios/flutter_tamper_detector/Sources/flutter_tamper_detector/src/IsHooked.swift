import Foundation
import MachO

class IsHooked {
    static func check() -> Bool {
        // Dynamic library injections are only relevant on real devices.
        #if targetEnvironment(simulator)
        return false
        #else
        return checkInjectedDylibs()
        #endif
    }
    
    // Low-level memory scan inspecting loaded dynamic link libraries (images) inside the process
    private static func checkInjectedDylibs() -> Bool {
        // Get the total number of currently loaded images in the memory space
        let count = _dyld_image_count()
        
        for i in 0..<count {
            // Safely retrieve the raw C-string pointer representation of the image name
            if let cName = _dyld_get_image_name(i) {
                let name = String(cString: cName)
                
                // Inspecting the absolute path paths for known hooking runtimes and tweaks
                if name.contains("Library/MobileSubstrate") || 
                   name.contains("FridaGadget") || 
                   name.contains("libfrida") || 
                   name.contains("SubstrateLoader") ||
                   name.contains("substitute") ||
                   name.contains("tweaks") {
                    return true // Malicious or unauthorized library injection found in memory
                }
            }
        }
        return false // Memory space clean
    }
}