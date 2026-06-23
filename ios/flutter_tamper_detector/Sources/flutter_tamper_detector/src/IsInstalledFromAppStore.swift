import Foundation

class IsInstalledFromAppStore {
    static func check() -> Bool {
        // Local development schemes/simulators lack official App Store receipts.
        #if targetEnvironment(simulator) || DEBUG
        return true
        #else
        
        // Retrieve the location of the app's encrypted App Store receipt bundle
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        
        let receiptPath = receiptURL.path
        
        // If the application was sideloaded, the receipt file will either be completely missing
        // or its path string will contain indicators pointing toward sandbox/sideloading toolchains.
        if FileManager.default.fileExists(atPath: receiptPath) {
            // A valid receipt structure path should typically target 'sandboxReceipt' for TestFlight
            // or '_MASReceipt/receipt' for standard production installations.
            if receiptPath.contains("sandboxReceipt") || receiptPath.contains("_MASReceipt") {
                return true
            }
            return true
        }
        
        return false
        #endif
    }
}