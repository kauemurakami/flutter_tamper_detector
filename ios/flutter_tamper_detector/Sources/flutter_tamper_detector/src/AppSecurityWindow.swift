import Foundation
import UIKit

/// Obscures app content when the app backgrounds or screen capture is active.
final class AppPrivacyWindow {
    static let shared = AppPrivacyWindow()

    private var blurView: UIVisualEffectView?
    private var preventCapture = false
    private var hideInSwitcher = true
    private var observers: [NSObjectProtocol] = []

    private init() {}

    /// Applies privacy behavior and registers lifecycle/capture observers once.
    func configure(preventScreenshot: Bool, hideInMenu: Bool) {
        preventCapture = preventScreenshot
        hideInSwitcher = hideInMenu
        if observers.isEmpty {
            let center = NotificationCenter.default
            observers.append(center.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil, queue: .main
            ) { [weak self] _ in self?.applyIfNeeded() })
            observers.append(center.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil, queue: .main
            ) { [weak self] _ in self?.removeOverlay() })
            observers.append(center.addObserver(
                forName: UIScreen.capturedDidChangeNotification,
                object: nil, queue: .main
            ) { [weak self] _ in self?.captureStateChanged() })
        }
        if preventCapture && (keyWindow()?.windowScene?.screen.isCaptured ?? false) {
            applyIfNeeded()
        } else if !hideInSwitcher && UIApplication.shared.applicationState == .active {
            removeOverlay()
        }
    }

    private func captureStateChanged() {
        guard preventCapture else { return }
        if (keyWindow()?.windowScene?.screen.isCaptured ?? false) { applyIfNeeded() }
        else if UIApplication.shared.applicationState == .active { removeOverlay() }
    }

    private func applyIfNeeded() {
        guard hideInSwitcher || (preventCapture && (keyWindow()?.windowScene?.screen.isCaptured ?? false)) else { return }
        guard let window = keyWindow(), blurView == nil else { return }
        let overlay = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        overlay.frame = window.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.accessibilityLabel = "Protected application content"
        window.addSubview(overlay)
        window.bringSubviewToFront(overlay)
        blurView = overlay
    }

    private func removeOverlay() {
        blurView?.removeFromSuperview()
        blurView = nil
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
