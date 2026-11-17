//
//  MarqueeText.swift
//  FreshMorning
//
//  Created by hb on 29/10/26.
//

import SwiftUI

/// A single-line text that scrolls horizontally in a continuous loop.
/// If the text fits inside the available width, it stays static.
///
/// - Parameters:
///   - text: The string to display.
///   - font: Font used for the text.
///   - speed: Scroll speed in points per second.
///   - gap: Space between the end of one copy and the start of the next.
///   - pauseDuration: Seconds to pause at the start position before each scroll
///     (also applies when the view first appears and when the text changes).
///   - fadeEdges: Width of the fade at the left/right edges (0 = no fade).
struct MarqueeText: View {
    let text: String
    var font: Font = .body
    var speed: Double = 40
    var gap: CGFloat = 40
    var pauseDuration: Double = 1
    var fadeEdges: CGFloat = 0

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var startDate = Date()

    private var shouldScroll: Bool {
        textWidth > containerWidth && containerWidth > 0
    }

    var body: some View {
        // Invisible text gives us the correct height and the container width.
        Text(text)
            .font(font)
            .lineLimit(1)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SizeReader { containerWidth = $0.width })
            .overlay(alignment: .leading) {
                TimelineView(.animation(paused: !shouldScroll)) { context in
                    HStack(spacing: gap) {
                        label
                        if shouldScroll { label }
                    }
                    .offset(x: shouldScroll ? offset(at: context.date) : 0)
                }
            }
            .clipped()
            .mask(edgeMask)
            .onChange(of: text) { _ in startDate = Date() }
            .onChange(of: gap) { _ in startDate = Date() }
    }

    // MARK: - Pieces

    private var label: some View {
        Text(text)
            .font(font)
            .lineLimit(1)
            .fixedSize()
            .background(SizeReader { textWidth = $0.width })
    }

    private func offset(at date: Date) -> CGFloat {
        // One loop = scroll by (text width + gap), after which the second copy
        // sits exactly where the first one started, so the pause looks seamless.
        let distance = Double(textWidth + gap)
        guard distance > 0, speed > 0 else { return 0 }

        let scrollTime = distance / speed
        let period = pauseDuration + scrollTime
        let elapsed = date.timeIntervalSince(startDate)
        let t = elapsed.truncatingRemainder(dividingBy: period)

        // Pause phase: stay at the start position.
        guard t >= pauseDuration else { return 0 }

        // Scroll phase.
        return -CGFloat((t - pauseDuration) * speed)
    }

    @ViewBuilder
    private var edgeMask: some View {
        if fadeEdges > 0 && shouldScroll {
            HStack(spacing: 0) {
                LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fadeEdges)
                Rectangle().fill(.black)
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: fadeEdges)
            }
        } else {
            Rectangle().fill(.black)
        }
    }
}

// MARK: - Size measuring helper

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct SizeReader: View {
    let onChange: (CGSize) -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: proxy.size)
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

// MARK: - Preview / Usage

struct MarqueeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Small gap
            MarqueeText(
                text: "Breaking news: SwiftUI marquee with a custom gap between texts",
                font: .headline,
                speed: 50,
                gap: 20
            )

            // Large gap + edge fade
            MarqueeText(
                text: "Breaking news: SwiftUI marquee with a custom gap between texts",
                font: .headline,
                speed: 50,
                gap: 120,
                fadeEdges: 16
            )

            // Short text: stays static
            MarqueeText(text: "Short text", font: .headline, gap: 40)
        }
        .padding()
        .frame(width: 320)
    }
}
