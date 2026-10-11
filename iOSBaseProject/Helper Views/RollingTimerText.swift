//
//  RollingTimerText.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import SwiftUI

struct RollingDigit: View {
    let digit: Int

    var body: some View {
        ZStack {
            Text("\(digit)")
                .id(digit)   // new id = SwiftUI treats it as a new view, so the transition runs
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    )
                )
        }
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .monospacedDigit()
        .frame(width: 14, height: 28)
        .clipped()   // hides the digit while it's outside the frame
    }
}

struct RollingTimerText: View {
    let seconds: Int

    var body: some View {
        let m = seconds / 60
        let s = seconds % 60

        HStack(spacing: 0) {
            RollingDigit(digit: m / 10)
            RollingDigit(digit: m % 10)
            Text(":")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            RollingDigit(digit: s / 10)
            RollingDigit(digit: s % 10)
        }
    }
}
