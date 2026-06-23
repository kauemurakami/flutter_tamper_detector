// Sources/flutter_tamper_detector/src/AppPrivacyWindow.swift
import Foundation
import UIKit

class AppPrivacyWindow {
    static let shared = AppPrivacyWindow()
    
    private var blurView: UIVisualEffectView?
    private var secureTextField: UITextField?
    private var isPreventScreenshotEnabled = false
    private var isHideInMenuEnabled = false
    private var isObserving = false

    func configure(preventScreenshot: Bool, hideInMenu: Bool) {
        self.isPreventScreenshotEnabled = preventScreenshot
        self.isHideInMenuEnabled = hideInMenu
        
        // Ejecuta na Main Thread de UI para garantir sincronia com a janela
        DispatchQueue.main.async {
            self.setupSecureScreenIfNeeded()
        }
        
        if !isObserving {
            isObserving = true
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(screenCaptureChanged), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
    }
    
    private func setupSecureScreenIfNeeded() {
        guard isPreventScreenshotEnabled else {
            secureTextField?.removeFromSuperview()
            secureTextField = nil
            return
        }
        
        if secureTextField == nil, let window = getKeyWindow() {
            // Cria o UITextField mascarado
            let textField = UITextField()
            textField.isSecureTextEntry = true
            textField.isUserInteractionEnabled = false // Não bloqueia os cliques no Flutter abaixo dele
            
            secureTextField = textField
            window.addSubview(textField)
            
            // Faz o campo seguro ocupar a tela inteira invisivelmente
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: window.topAnchor),
                textField.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                textField.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: window.trailingAnchor)
            ])
            
            // Vincula a camada de renderização do Flutter ao container seguro do texto
            if let secureContainer = textField.layer.sublayers?.first {
                window.layer.superlayer?.addSublayer(secureContainer)
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
    }

    @objc private func screenCaptureChanged() {
        guard isPreventScreenshotEnabled else { return }
        
        // Checagem via API nativa
        if UIScreen.main.isCaptured {
            applyBlurScreen()
        } else {
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
        
        // Garante que o borrão fique no topo absoluto de tudo
        window.addSubview(visualBlurEffectView)
        window.bringSubviewToFront(visualBlurEffectView)
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