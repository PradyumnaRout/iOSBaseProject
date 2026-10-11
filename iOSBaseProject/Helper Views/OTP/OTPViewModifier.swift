//
//  OTPViewModifier.swift
//  FreshMorning
//
//  Created by hb on 01/10/26.
//

import Foundation
import SwiftUI

struct OTPModifier: ViewModifier {
    var isFocused: Bool
    var isFilled: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isFilled
                        ? Color(hex: "#282F49")
                        : isFocused
                        ? Color(hex: "#3E4660")
                        : Color(hex: "#131A33")
                    )
                    .shadow(
                        color: isFocused
                        ? Color(hex: "#4D44E3").opacity(0.65)
                        : .clear,
                        radius: 6,
                        x: 0,
                        y: 8
                    )
            }
    }
}
