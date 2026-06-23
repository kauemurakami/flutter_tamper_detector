// Sources/flutter_tamper_detector/src/AppPrivacyWindow.swift
import Foundation
import UIKit

class AppPrivacyWindow {
    static let shared = AppPrivacyWindow()
    
    private var blurView: UIVisualEffectView?
    private var secureTextField: UITextField?
    private var containerView: UIView?
    private var isPreventScreenshotEnabled = false
    private var isHideInMenuEnabled = false
    private var isObserving = false

    func configure(preventScreenshot: Bool, hideInMenu: Bool) {
        self.isPreventScreenshotEnabled = preventScreenshot
        self.isHideInMenuEnabled = hideInMenu
        
        setupSecureTextFieldIfNeeded()
        
        if !isObserving {
            isObserving = true
            // Listen for backgrounding/foregrounding events to handle app switcher masking
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            // Listen for screen recording changes
            NotificationCenter.default.addObserver(self, selector: #selector(screenCaptureChanged), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
        
        // Immediate run check for screen recording upon configuration
        screenCaptureChanged()
    }
    
    private func setupSecureTextFieldIfNeeded() {
        guard isPreventScreenshotEnabled else {
            // If disabled, restore original structure if needed
            if let flutterView = containerView?.subviews.first, let window = getKeyWindow() {
                window.addSubview(flutterView)
            }
            containerView?.removeFromSuperview()
            containerView = nil
            secureTextField = nil
            return
        }
        
        if secureTextField == nil, let window = getKeyWindow() {
            let textField = UITextField()
            textField.isSecureTextEntry = true
            secureTextField = textField
            
            // Look for the inner UITextField secure container view inside its subviews hierarchy
            // This grabs the hardware-protected layer container from iOS
            if let secureContainer = textField.subviews.first(where: { String(describing: type(of: $0)).contains("Canvas") || $0.description.contains("Canvas") }) ?? textField.subviews.first {
                self.containerView = secureContainer
                
                window.addSubview(secureContainer)
                secureContainer.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    secureContainer.topAnchor.constraint(equalTo: window.topAnchor),
                    secureContainer.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                    secureContainer.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    secureContainer.trailingAnchor.constraint(equalTo: window.trailingAnchor)
                ])
                
                // Safely embed Flutter's host view controller layer directly into the secure hardware pipeline
                if let flutterView = window.rootViewController?.view {
                    secureContainer.addSubview(flutterView)
                    flutterView.frame = window.bounds
                    flutterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                }
            }
        }
    }

    @objc private func didEnterBackground() {
        if isHideInMenuEnabled {
            applyBlurScreen()
        }
    }

    @objc private func willEnterForeground() {
        removeBlurScreen()
        // Re-verify if a recording tool started while the app was suspended
        screenCaptureChanged()
    }

    @objc private func screenCaptureChanged() {
        guard isPreventScreenshotEnabled else { return }
        
        // UIScreen.main.isCaptured evaluates true if screen recording, AirPlay, or mirroring is running
        if UIScreen.main.isCaptured {
            applyBlurScreen()
        } else {
            // Do not remove blur if the app is currently sitting in the background
            if UIApplication.shared.applicationState != .background {
                removeBlurScreen()
            }
        }
    }

    private func applyBlurScreen() {
        guard blurView == nil, let window = getKeyWindow() else { return }
        
        let blurEffect = UIBlurEffect(style: .dark)
        let visualBlurEffectView = UIVisualEffectView(effect: blurEffect)
        visualBlurEffectView.frame = window.bounds
        visualBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        window.addSubview(visualBlurEffectView)
        self.blurView = visualBlurEffectView
    }

    private func removeBlurScreen() {
        blurView?.removeFromSuperview()
        blurView = nil
    }

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        }
        return UIApplication.shared.keyWindow
    }
}