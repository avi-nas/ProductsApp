import SwiftUI

struct HorizontalSizeClassLayout<Compact: View, Regular: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let compact: Compact
    private let regular: Regular

    init(
        @ViewBuilder compact: () -> Compact,
        @ViewBuilder regular: () -> Regular
    ) {
        self.compact = compact()
        self.regular = regular()
    }

    @ViewBuilder
    var body: some View {
        if horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize {
            regular
        } else {
            compact
        }
    }
}

struct NativeSplitArrangement<Primary: View, Secondary: View, Fallback: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let primary: Primary
    private let secondary: Secondary
    private let fallback: Fallback

    init(
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary,
        @ViewBuilder fallback: () -> Fallback
    ) {
        self.primary = primary()
        self.secondary = secondary()
        self.fallback = fallback()
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 27.1, *),
           horizontalSizeClass == .regular,
           !dynamicTypeSize.isAccessibilitySize {
            ArrangementView {
                primary
            } secondary: {
                secondary
            }
            .arrangementViewStyle(.split.axes(.horizontal))
        } else {
            fallback
        }
    }
}
