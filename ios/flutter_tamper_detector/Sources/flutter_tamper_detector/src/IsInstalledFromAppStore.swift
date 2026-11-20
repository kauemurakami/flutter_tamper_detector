import Foundation

/// Provides a weak local indication of App Store/TestFlight distribution.
enum IsInstalledFromAppStore {
    /// Returns whether the bundle contains an App Store receipt file.
    /// Receipt presence must not be treated as a validated or unmodified receipt.
    static func hasReceipt() -> Bool {
        #if targetEnvironment(simulator) || DEBUG
        return true
        #else
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return FileManager.default.fileExists(atPath: receiptURL.path)
        #endif
    }
}
