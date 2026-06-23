import Foundation

class IsJailbreak {
    static func check() -> Bool {
        // If running on the official simulator, it doesn't check for jailbreak to avoid false positives.
        #if targetEnvironment(simulator)
        return false
        #else
        return checkSuspiciousPaths() || checkSandboxViolation()
        #endif
    }
    
    // 1. Low-level C check (POSIX stat) against jailbreak directories and managers.
    private static func checkSuspiciousPaths() -> Bool {
        let paths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in paths {
            var s = stat()
            // stat() returns 0 if the file exists within the iPhone's file system
            if stat(path, &s) == 0 {
                return true
            }
        }
        return false
    }
    
    // 2. Dynamic test for iOS Sandbox violation
    private static func checkSandboxViolation() -> Bool {
        let testString = "Jailbreak_Tamper_Test"
        let path = "/private/jailbreak_test.txt"
        
        do {
            // A regular app inside the sandbox will receive an 'Access Denied' error here.
            // If the kernel has been modified by a jailbreak, writing will be allowed.
            try testString.write(toFile: path, atomically: true, encoding: .utf8)
            
            // If it successfully writes, remove the test file and confirm the violation
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            // Normal and secure behavior: writing is blocked by the Sandbox
            return false
        }
    }
}