import Foundation

class IsSimulator {
    static func check() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}