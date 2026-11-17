//
//  PopupCenter.swift
//  FreshMorning
//
//  Created by hb on 30/10/26.
//

import Foundation
import SwiftUI

// MARK: - Presenting on key window
@MainActor
final class PopupCenter {
    
    static let shared = PopupCenter()
    
    private var popupWindow: UIWindow?
    private weak var previousKeyWindow: UIWindow?
    
    private init() {}
    
    // MARK: - Show Popup
    func show<Content: View>(
        @ViewBuilder content: () -> Content
    ) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else {
            return
        }
        
        // Avoid duplicate popup windows
        dismiss()
        
        previousKeyWindow = scene.keyWindow
        
        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        
        let hostingController = UIHostingController(
            rootView: AnyView(
                content()
            )
        )
        
        hostingController.view.backgroundColor = .clear
        
        window.rootViewController = hostingController
        
        popupWindow = window
        
        window.isHidden = false
        window.makeKey()
    }
    
    // MARK: - Dismiss Popup
    
    func dismiss() {
        popupWindow?.isHidden = true
        popupWindow?.rootViewController = nil
        popupWindow = nil
        
        previousKeyWindow?.makeKey()
        previousKeyWindow = nil
    }
}
