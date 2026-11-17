//
//  ToastMessage.swift
//  FreshMorning
//
//  Created by hb on 29/10/26.
//

import SwiftUI
import UIKit
import Combine

// =============================================================================
// Toast.swift  (iOS 15+)
//
// Show a toast from ANYWHERE: SwiftUI views, UIKit controllers, view models,
// services, network callbacks, background threads. No view reference needed.
//
//   Toast.show(subtitle: "Saved")
//
//   Toast.show(
//       title: "Upload complete",
//       subtitle: "3 files were uploaded",
//       image: UIImage(systemName: "checkmark.circle.fill"),
//       from: .bottom,                              // top / bottom / leading / trailing
//       swipeToDismiss: [.bottom, .leading],        // developer decides; nil = swipe back to entry edge
//       duration: 3                                 // default 2s, <= 0 means "stay until dismissed"
//   )
//
//   Toast.dismiss()
// =============================================================================

// MARK: - Public API

enum ToastEdge: Hashable, Sendable {
    case top, bottom, leading, trailing

    static let all: Set<ToastEdge> = [.top, .bottom, .leading, .trailing]
}

struct ToastItem: @unchecked Sendable {
    var title: String?              // optional
    var subtitle: String            // required
    var image: UIImage?             // optional
    var edge: ToastEdge             // where the toast enters from (and leaves to on timeout)
    var dismissDirections: Set<ToastEdge>   // swipe directions that remove the toast
    var duration: TimeInterval      // auto-remove time. <= 0 disables auto-remove

    init(
        title: String? = nil,
        subtitle: String,
        image: UIImage? = nil,
        edge: ToastEdge = .top,
        dismissDirections: Set<ToastEdge>? = nil,
        duration: TimeInterval = 2
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.edge = edge
        self.dismissDirections = dismissDirections ?? [edge]
        self.duration = duration
    }
}

enum Toast {
    /// Shows a toast. Safe to call from any thread. A new toast replaces the current one.
    static func show(
        title: String? = nil,
        subtitle: String,
        image: UIImage? = nil,
        from edge: ToastEdge = .top,
        swipeToDismiss: Set<ToastEdge>? = nil,
        duration: TimeInterval = 2
    ) {
        show(ToastItem(
            title: title,
            subtitle: subtitle,
            image: image,
            edge: edge,
            dismissDirections: swipeToDismiss,
            duration: duration
        ))
    }

    static func show(_ item: ToastItem) {
        Task { @MainActor in ToastCenter.shared.present(item) }
    }

    /// Dismisses the current toast (animated).
    static func dismiss() {
        Task { @MainActor in ToastCenter.shared.dismiss() }
    }
}

// MARK: - Presenter (own UIWindow, independent of any view hierarchy)

@MainActor
private final class ToastCenter {
    static let shared = ToastCenter()

    private var window: ToastWindow?
    private var controller: ToastController?

    func present(_ item: ToastItem) {
        teardown()

        let controller = ToastController()
        let root = ToastView(item: item, controller: controller) { [weak self, weak controller] in
            guard let self, let controller, self.controller === controller else { return }
            self.teardown()
        }

        let host = UIHostingController(rootView: root)
        host.view.backgroundColor = .clear

        let window: ToastWindow
        if let scene = activeScene() {
            window = ToastWindow(windowScene: scene)
        } else {
            // Apps without a scene lifecycle (AppDelegate-only) have no UIWindowScene.
            window = ToastWindow(frame: UIScreen.main.bounds)
        }
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.rootViewController = host
        window.controller = controller
        window.isHidden = false      // visible, but does NOT become key window

        self.window = window
        self.controller = controller

        var message = item.subtitle
        if let title = item.title, !title.isEmpty { message = title + ". " + message }
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    func dismiss() {
        controller?.dismissPublisher.send()
    }

    private func teardown() {
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
        controller = nil
    }

    private func activeScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }
}

private final class ToastController: @unchecked Sendable {
    let dismissPublisher = PassthroughSubject<Void, Never>()
    /// Current on-screen frame of the card, used so touches outside the toast fall through to the app.
    var interactiveFrame: CGRect = .zero
}

private final class ToastWindow: UIWindow {
    var controller: ToastController?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        guard let controller, !controller.interactiveFrame.isEmpty else {
            return hitView
        }
        if !controller.interactiveFrame.insetBy(dx: -24, dy: -24).contains(point) {
            return nil
        }
        return hitView
    }
}

// MARK: - Toast View

private struct ToastView: View {
    let item: ToastItem
    let controller: ToastController
    let onFinished: @MainActor () -> Void

    @Environment(\.layoutDirection) private var layoutDirection

    @State private var cardSize: CGSize = .zero
    @State private var restingFrame: CGRect = .zero
    @State private var isPresented = false      // card is on screen
    @State private var isDismissing = false
    @State private var exitEdge: ToastEdge?
    @State private var drag: CGSize = .zero
    @State private var isDragging = false
    @State private var timerTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geo in
            card
                .background(
                    GeometryReader { Color.clear.preference(key: CardSizeKey.self, value: $0.size) }
                )
                .onPreferenceChange(CardSizeKey.self) { cardSizeChanged($0) }
                .background(
                    GeometryReader { Color.clear.preference(key: CardFrameKey.self, value: $0.frame(in: .global)) }
                )
                .onPreferenceChange(CardFrameKey.self) { frame in
                    restingFrame = frame
                    controller.interactiveFrame = frame
                }
                .offset(currentOffset(in: geo))
                .highPriorityGesture(dragGesture, including: item.dismissDirections.isEmpty ? .none : .all)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity,
                       alignment: item.edge == .bottom ? .bottom : .top)
        }
        .onAppear { animateIn() }
        .onReceive(controller.dismissPublisher) { dismiss(towards: item.edge) }
        .onDisappear { timerTask?.cancel() }
    }

    // MARK: Card

    private var card: some View {
        let hasTitle = !(item.title ?? "").isEmpty

        return HStack(spacing: 12) {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }
            VStack(alignment: .leading, spacing: 2) {
                if hasTitle, let title = item.title {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(hasTitle ? .secondary : .primary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        .frame(maxWidth: 500)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    // MARK: Positioning

    private func currentOffset(in geo: GeometryProxy) -> CGSize {
        isPresented ? drag : offscreen(exitEdge ?? item.edge, in: geo)
    }

    private func offscreen(_ edge: ToastEdge, in geo: GeometryProxy) -> CGSize {
        let safe = geo.safeAreaInsets
        let horizontal = geo.size.width + max(safe.leading, safe.trailing) + 60
        let h = cardSize.height > 0 ? cardSize.height : 70
        switch edge {
        case .top:
            let d = (item.edge == .bottom) ? (geo.size.height + safe.bottom + h + 40) : (h + safe.top + 40)
            return CGSize(width: 0, height: -d)
        case .bottom:
            let d = (item.edge == .top) ? (geo.size.height + safe.top + h + 40) : (h + safe.bottom + 40)
            return CGSize(width: 0, height: d)
        case .leading:  return CGSize(width: xSign(for: .leading) * horizontal, height: 0)
        case .trailing: return CGSize(width: xSign(for: .trailing) * horizontal, height: 0)
        }
    }

    /// -1 = screen's left, +1 = screen's right (respects right-to-left layouts).
    private func xSign(for edge: ToastEdge) -> CGFloat {
        let isLeft = (edge == .leading) == (layoutDirection == .leftToRight)
        return isLeft ? -1 : 1
    }

    // MARK: Lifecycle

    private func cardSizeChanged(_ size: CGSize) {
        cardSize = size
    }

    private func updateInteractiveFrame() {
        guard !restingFrame.isEmpty else { return }
        controller.interactiveFrame = restingFrame.offsetBy(dx: drag.width, dy: drag.height)
    }

    private func animateIn() {
        Task { @MainActor in
            // Let the off-screen position render first, then animate in.
            try? await Task.sleep(nanoseconds: 50_000_000)
            guard !isDismissing else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { isPresented = true }
            updateInteractiveFrame()
            startTimer()
        }
    }

    private func startTimer() {
        timerTask?.cancel()
        guard item.duration > 0 else { return }
        timerTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(item.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            dismiss(towards: item.edge)
        }
    }

    private func dismiss(towards edge: ToastEdge) {
        guard !isDismissing else { return }
        isDismissing = true
        timerTask?.cancel()
        exitEdge = edge
        controller.interactiveFrame = .zero
        withAnimation(.easeIn(duration: 0.25)) {
            isPresented = false
            drag = .zero
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            onFinished()
        }
    }

    // MARK: Swipe to dismiss

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                guard !isDismissing else { return }
                if !isDragging {
                    isDragging = true
                    timerTask?.cancel()          // don't auto-dismiss while the user is holding it
                }
                drag = constrained(value.translation)
                updateInteractiveFrame()
            }
            .onEnded { value in
                guard !isDismissing else { return }
                isDragging = false

                let hEdge = horizontalEdge(for: value.translation.width)
                let vEdge = verticalEdge(for: value.translation.height)

                let hDist = abs(value.translation.width)
                let vDist = abs(value.translation.height)
                let hPred = abs(value.predictedEndTranslation.width)
                let vPred = abs(value.predictedEndTranslation.height)

                let allowH = item.dismissDirections.contains(hEdge)
                let allowV = item.dismissDirections.contains(vEdge)

                let hPassed = allowH && (hDist > 20 || hPred > 60)
                let vPassed = allowV && (vDist > 20 || vPred > 60)

                if hPassed && vPassed {
                    if hDist >= vDist {
                        dismiss(towards: hEdge)
                    } else {
                        dismiss(towards: vEdge)
                    }
                } else if hPassed {
                    dismiss(towards: hEdge)
                } else if vPassed {
                    dismiss(towards: vEdge)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { drag = .zero }
                    updateInteractiveFrame()
                    startTimer()
                }
            }
    }

    /// Follows finger along allowed axes, applying smooth resistance to disallowed axes.
    private func constrained(_ t: CGSize) -> CGSize {
        let hEdge = horizontalEdge(for: t.width)
        let vEdge = verticalEdge(for: t.height)

        let allowH = item.dismissDirections.contains(hEdge)
        let allowV = item.dismissDirections.contains(vEdge)

        let x = allowH ? t.width : rubber(t.width)
        let y = allowV ? t.height : rubber(t.height)
        return CGSize(width: x, height: y)
    }

    private func rubber(_ value: CGFloat) -> CGFloat {
        let sign: CGFloat = value < 0 ? -1 : 1
        return sign * min(abs(value) * 0.15, 12)
    }

    private func horizontalEdge(for width: CGFloat) -> ToastEdge {
        let isLeft = (width < 0) == (layoutDirection == .leftToRight)
        return isLeft ? .leading : .trailing
    }

    private func verticalEdge(for height: CGFloat) -> ToastEdge {
        height < 0 ? .top : .bottom
    }
}

// MARK: - Preference keys

private struct CardSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

private struct CardFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}


/// `Usage`::


//                Toast.show(
//                    title: "Upload complete",
//                    subtitle: "3 files were uploaded",
//                    image: UIImage(systemName: "checkmark.circle.fill"),
//                    from: .leading,
//                    swipeToDismiss: [.leading, .trailing],
//                    duration: 3
//                )

