import SwiftUI

extension VerticalAlignment {
    private enum BubbleBottomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.bottom]
        }
    }

    public static let bubbleBottom = VerticalAlignment(BubbleBottomAlignment.self)
}
