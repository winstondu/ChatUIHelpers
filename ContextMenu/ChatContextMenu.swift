//
//  ChatContextMenu.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI

/// Observable state for context menu presentation.
/// Use this to coordinate between anchor views and the host that renders the menu.
@Observable
public final class ContextMenuPresentation {
    public var presentedMenuId: String?

    public init() {}

    public func present(id: String) {
        presentedMenuId = id
    }

    public func dismiss() {
        presentedMenuId = nil
    }

    public func isPresented(id: String) -> Bool {
        presentedMenuId == id
    }

    public func toggle(id: String) {
        if presentedMenuId == id {
            dismiss()
        } else {
            present(id: id)
        }
    }
}

public struct ChatContextMenuStyle: Sendable {
    public var background: Color
    public var border: Color
    public var divider: Color
    public var iconTint: Color
    public var textColor: Color
    public var font: Font
    public var cornerRadius: CGFloat
    public var shadowColor: Color
    public var shadowRadius: CGFloat
    public var shadowY: CGFloat

    public init(
        background: Color = .secondary,
        border: Color = Color.gray.opacity(0.25),
        divider: Color = Color.gray.opacity(0.25),
        iconTint: Color = .secondary,
        textColor: Color = .primary,
        font: Font = .system(size: 16),
        cornerRadius: CGFloat = 30,
        shadowColor: Color = .black.opacity(0.1),
        shadowRadius: CGFloat = 20,
        shadowY: CGFloat = 3
    ) {
        self.background = background
        self.border = border
        self.divider = divider
        self.iconTint = iconTint
        self.textColor = textColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
    }
}

public struct ChatContextMenuItem: Identifiable, Equatable, @unchecked Sendable {
    public let id: String
    public let icon: Image
    public let title: String
    public let action: () -> Void

    public init(id: String, icon: Image, title: String, action: @escaping () -> Void) {
        self.id = id
        self.icon = icon
        self.title = title
        self.action = action
    }

    public init(icon: Image, title: String, action: @escaping () -> Void) {
        self.init(id: UUID().uuidString, icon: icon, title: title, action: action)
    }

    public static func == (lhs: ChatContextMenuItem, rhs: ChatContextMenuItem) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

/// Dismiss animation style for the context menu
public enum ChatContextMenuDismissStyle {
    /// Instant fade out - no stagger, just fade the whole menu
    case fade
    /// Reverse unfurl - top items disappear first, then container shrinks
    case reverseUnfurl
}

public struct ChatContextMenu: View, Equatable {
    nonisolated let items: [ChatContextMenuItem]
    let onDismiss: () -> Void
    /// Controls the unfurl animation state (false = collapsed, true = expanded)
    @Binding var isExpanded: Bool
    /// How the menu should animate when dismissing
    var dismissStyle: ChatContextMenuDismissStyle = .fade
    var style: ChatContextMenuStyle = ChatContextMenuStyle()

    public init(
        items: [ChatContextMenuItem],
        onDismiss: @escaping () -> Void,
        isExpanded: Binding<Bool>,
        dismissStyle: ChatContextMenuDismissStyle = .fade,
        style: ChatContextMenuStyle = ChatContextMenuStyle()
    ) {
        self.items = items
        self.onDismiss = onDismiss
        self._isExpanded = isExpanded
        self.dismissStyle = dismissStyle
        self.style = style
    }

    public nonisolated static func == (lhs: ChatContextMenu, rhs: ChatContextMenu) -> Bool {
        lhs.items == rhs.items
    }

    /// Height of a single menu row
    static let rowHeight: CGFloat = 48

    /// Vertical padding for the menu container
    private enum Padding {
        static let top: CGFloat = 8
        static let bottom: CGFloat = 8
    }

    /// Unfurl animation constants
    private enum UnfurlAnimation {
        static let slideOffset: CGFloat = 12          // How far items slide up
        static let itemDuration: Double = 0.1        // Each item's fade/slide duration
        static let containerDuration: Double = 0.02   // Container height animation duration
        static let staggerInterval: Double = 0.005     // 30ms between items for reverse unfurl
        static let fadeDuration: Double = 0.05        // Duration for instant fade dismiss
    }

    /// Total vertical padding (top + bottom)
    private var verticalPadding: CGFloat {
        Padding.top + Padding.bottom
    }

    /// Calculate the container height based on expansion state
    /// Animates from 1 row height + padding to full height + padding
    private var containerHeight: CGFloat {
        let contentHeight = isExpanded ? fullHeight : Self.rowHeight
        return contentHeight + verticalPadding
    }

    /// Inverse of easeOut curve: given progress (0-1), returns time (0-1)
    /// For easeOut: progress = 1 - (1 - t)², so t = 1 - √(1 - progress)
    private func easeOutInverse(_ progress: Double) -> Double {
        let clamped = max(0, min(1, progress))
        return 1 - sqrt(1 - clamped)
    }

    /// Calculate the delay for an item when appearing (unfurling).
    /// Bottom items (higher index) appear first since they need less height.
    private func appearDelay(for index: Int) -> Double {
        guard items.count > 1 else { return 0 }

        // Container height animates from (1 row) to (N rows) over containerDuration
        // Item at index i should appear when height reaches row (N - i)
        // Since we're using easeOut, we need to find what time corresponds to that height

        let itemCount = Double(items.count)

        // Height progress needed for this item's row to be revealed
        // index 0 (top) needs full height (progress = 1.0)
        // index N-1 (bottom) needs 1 row (progress = 0.0)
        let targetHeightProgress = (itemCount - Double(index) - 1) / (itemCount - 1)

        // Convert progress to time using easeOut inverse
        let time = easeOutInverse(targetHeightProgress)

        return time * UnfurlAnimation.containerDuration
    }

    /// Calculate the delay for an item when disappearing (reverse unfurl).
    /// Top items (lower index) disappear first.
    private func disappearDelay(for index: Int) -> Double {
        guard items.count > 1 else { return 0 }
        // Top items first: index 0 has 0 delay, index N-1 has max delay
        return Double(index) * UnfurlAnimation.staggerInterval
    }

    /// Get the animation for an item based on current expansion state
    private func itemAnimation(for index: Int) -> Animation {
        if isExpanded {
            // Appearing: use calculated delay based on height reveal
            return .easeOut(duration: UnfurlAnimation.itemDuration)
                .delay(appearDelay(for: index))
        } else {
            // Disappearing: depends on dismiss style
            switch dismissStyle {
            case .fade:
                // All items fade together, no stagger
                return .easeOut(duration: UnfurlAnimation.fadeDuration)
            case .reverseUnfurl:
                // Top items first
                return .easeOut(duration: UnfurlAnimation.itemDuration)

            }
        }
    }

    /// Get the animation for a divider based on current expansion state.
    /// Divider at index i sits between item i and item i+1.
    /// - Appear: animates with item i+1 (revealed when that row appears)
    /// - Disappear: animates with item i (disappears with the item above)
    private func dividerAnimation(for index: Int) -> Animation {
        if isExpanded {
            // Appearing: divider is revealed when the row below (item i+1) is revealed
            return .easeOut(duration: UnfurlAnimation.itemDuration)
                .delay(appearDelay(for: index + 1))
        } else {
            // Disappearing: divider goes with the item above it
            switch dismissStyle {
            case .fade:
                return .easeOut(duration: UnfurlAnimation.fadeDuration)
            case .reverseUnfurl:
                return .easeOut(duration: UnfurlAnimation.itemDuration)
            }
        }
    }

    /// Get the container animation based on current expansion state
    private var containerAnimation: Animation {
        if isExpanded {
            return .easeOut(duration: UnfurlAnimation.containerDuration)
        } else {
            switch dismissStyle {
            case .fade:
                return .easeOut(duration: UnfurlAnimation.fadeDuration)
            case .reverseUnfurl:
                return .easeOut(duration: UnfurlAnimation.containerDuration)
            }
        }
    }

    /// Full height of the menu (all items)
    private var fullHeight: CGFloat {
        CGFloat(items.count) * Self.rowHeight
    }

    @ViewBuilder
    private func menuItemButton(for item: ChatContextMenuItem, at index: Int) -> some View {
        Button {
            item.action()
            onDismiss()
        } label: {
            HStack(spacing: 12) {
                item.icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(style.iconTint)
                    .frame(width: 20, height: 20)

                Text(item.title)
                    .font(style.font)

                Spacer()
            }
            .foregroundStyle(style.textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isExpanded ? 1 : 0)
        .offset(y: isExpanded ? 0 : UnfurlAnimation.slideOffset)
        .animation(itemAnimation(for: index), value: isExpanded)
    }

    @ViewBuilder
    private func divider(at index: Int) -> some View {
        Rectangle()
            .fill(style.divider)
            .frame(height: 1)
            .padding(.horizontal, 12)
            .opacity(isExpanded ? 1 : 0)
            .offset(y: isExpanded ? 0 : UnfurlAnimation.slideOffset)
            .animation(dividerAnimation(for: index), value: isExpanded)
    }

    @ViewBuilder
    private var itemsOverlay: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                menuItemButton(for: item, at: index)

                if index < items.count - 1 {
                    divider(at: index)
                }
            }
        }
        .padding(.top, Padding.top)
        .padding(.bottom, Padding.bottom)
        .frame(height: fullHeight + verticalPadding, alignment: .bottom)
    }

    /// Scale factor for the container based on expansion state
    private var containerScale: CGFloat {
        let collapsedHeight = Self.rowHeight + verticalPadding
        let expandedHeight = fullHeight + verticalPadding
        return isExpanded ? 1 : collapsedHeight / expandedHeight
    }

    public var body: some View {
        // Fixed outer frame provides stable bottom anchor
        ZStack(alignment: .bottom) {
            // Container background that scales from bottom
            style.background
                .frame(minWidth: 180)
                .frame(height: fullHeight + verticalPadding)
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
                .scaleEffect(y: containerScale, anchor: .bottom)
                .animation(containerAnimation, value: isExpanded)
                .overlay {
                    RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                        .stroke(style.border, lineWidth: 1)
                }
                // Apply styling AFTER scaleEffect so corners/stroke aren't distorted
                .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
                .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: style.shadowY)

            // Items overlay - not scaled, clipped by container bounds
            itemsOverlay
                .frame(height: fullHeight + verticalPadding, alignment: .bottom)
                .clipShape(
                    Rectangle()
                        .scale(y: containerScale, anchor: .bottom)
                )
                .animation(containerAnimation, value: isExpanded)
        }
        .frame(height: fullHeight + verticalPadding)
    }
}

/// Preference value for propagating anchor position and menu configuration up the view hierarchy.
public struct ContextMenuAnchorValue {
    let id: String
    let anchor: Anchor<CGRect>
    let items: [ChatContextMenuItem]
    let offset: CGSize
}

/// Preference key for context menu anchors.
public struct ContextMenuAnchorKey: PreferenceKey {
    public static var defaultValue: ContextMenuAnchorValue? { nil }

    public static func reduce(value: inout ContextMenuAnchorValue?, nextValue: () -> ContextMenuAnchorValue?) {
        value = value ?? nextValue()
    }
}

public extension View {
    /// Marks this view as the anchor point for a context menu.
    /// The menu will be rendered by a `contextMenuHost` modifier higher in the view hierarchy.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for this menu anchor.
    ///   - presentation: Shared presentation state object.
    ///   - items: The menu items to display.
    ///   - offset: Additional offset from the anchor position.
    func contextMenuAnchor(
        id: String,
        presentation: ContextMenuPresentation,
        items: [ChatContextMenuItem],
        offset: CGSize = .zero
    ) -> some View {
        self.anchorPreference(key: ContextMenuAnchorKey.self, value: .bounds) { anchor in
            ContextMenuAnchorValue(
                id: id,
                anchor: anchor,
                items: items,
                offset: offset
            )
        }
    }

    /// Hosts context menus for any `contextMenuAnchor` views within its subtree.
    /// Apply this modifier OUTSIDE of any glass effect hierarchy to ensure proper rendering.
    ///
    /// - Parameters:
    ///   - presentation: Shared presentation state object.
    ///   - dismissStyle: How the menu should animate when dismissing. Defaults to `.fade`.
    func contextMenuHost(
        presentation: ContextMenuPresentation,
        dismissStyle: ChatContextMenuDismissStyle = .fade,
        style: ChatContextMenuStyle = ChatContextMenuStyle()
    ) -> some View {
        self.overlayPreferenceValue(ContextMenuAnchorKey.self) { anchorValue in
            ContextMenuHostOverlay(
                anchorValue: anchorValue,
                presentation: presentation,
                dismissStyle: dismissStyle,
                style: style
            )
        }
    }
}

/// Internal view that renders the context menu at the host level.
private struct ContextMenuHostOverlay: View {
    let anchorValue: ContextMenuAnchorValue?
    let presentation: ContextMenuPresentation
    var dismissStyle: ChatContextMenuDismissStyle = .fade
    var style: ChatContextMenuStyle

    @State private var isExpanded: Bool = false

    private var isPresented: Bool {
        guard let value = anchorValue else { return false }
        return presentation.isPresented(id: value.id)
    }

    /// Calculate how long to wait before removing the view after dismiss animation starts
    private var dismissDuration: Int {
        guard let value = anchorValue else { return 150 }
        switch dismissStyle {
        case .fade:
            return 150 // 0.15s fade
        case .reverseUnfurl:
            // Items animate out with stagger, then container shrinks
            let itemCount = value.items.count
            let staggerTime = Double(itemCount - 1) * 0.01 // staggerInterval
            let itemDuration = 0.1
            let containerDuration = 0.2
            let totalTime = staggerTime + itemDuration + containerDuration
            return Int(totalTime * 1000)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            if let value = anchorValue, isPresented {
                let rect = proxy[value.anchor]

                // Scrim for tap-outside-to-dismiss
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissMenu()
                    }
                    .allowsHitTesting(isExpanded)

                // Context menu positioned relative to anchor
                // Bottom of menu anchors to top of the button
                ChatContextMenu(
                    items: value.items,
                    onDismiss: {
                        dismissMenu()
                    },
                    isExpanded: $isExpanded,
                    dismissStyle: dismissStyle,
                    style: style
                )
                .fixedSize()
                .alignmentGuide(.leading) { d in -rect.minX - value.offset.width }
                .alignmentGuide(.top) { d in d[.bottom] - rect.minY - value.offset.height + 8 }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .allowsHitTesting(isExpanded)
                .onAppear {
                    DispatchQueue.main.async {
                        isExpanded = true
                    }
                }
            }
        }
        .onChange(of: isPresented) { _, newValue in
            // When the menu is dismissed by toggling presentation state
            // (e.g. tapping the plus button again), we won't go through
            // `dismissMenu()`. Reset `isExpanded` here so that the next
            // presentation always starts from the collapsed state and
            // the unfurl animation can run.
            if !newValue {
                isExpanded = false
            }
        }
    }

    private func dismissMenu() {
        withAnimation {
            isExpanded = false
        }
        Task {
            try? await Task.sleep(for: .milliseconds(dismissDuration))
            presentation.dismiss()
        }
    }
}

#Preview("Context Menu Only") {
    ChatContextMenuPreview()
}

private struct ChatContextMenuPreview: View {
    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack {
            Color(hex: 0xF5EEE5).ignoresSafeArea()

            VStack {
                Spacer()

                ChatContextMenu(
                    items: [
                        ChatContextMenuItem(
                            icon: Image(systemName: "photo"),
                            title: "Send Photo",
                            action: { }
                        ),
                        ChatContextMenuItem(
                            icon: Image(systemName: "camera"),
                            title: "Take Photo",
                            action: { }
                        ),
                        ChatContextMenuItem(
                            icon: Image(systemName: "face.smiling"),
                            title: "Send Reaction",
                            action: { }
                        )
                    ],
                    onDismiss: { },
                    isExpanded: $isExpanded
                )
                .padding()

                Button(isExpanded ? "Collapse" : "Expand") {
                    isExpanded.toggle()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}
