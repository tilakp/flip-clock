import SwiftUI

/// One half of a flip card.
///
/// The whole card is drawn and then cropped to the requested half. Deriving both halves from the
/// same full-size card is what keeps a digit in register across the split: the previous approach
/// selected each half with its own chain of negative paddings, which dropped a thin band of the
/// glyph's middle and left strokes that cross the split visibly offset.
struct SingleFlipView: View {

    init(text: String, type: FlipType, fontSize: CGFloat, tileSize: CGSize, cornerRadius: CGFloat) {
        self.text = text
        self.type = type
        self.fontSize = fontSize
        self.tileSize = tileSize
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .fontWeight(.heavy)
            .foregroundColor(.textColor)
            .fixedSize()
            .frame(width: tileSize.width, height: tileSize.height)
            .background(Color.flipBackground)
            .frame(height: tileSize.height / 2, alignment: type.alignment)
            .clipShape(type.shape(cornerRadius: cornerRadius))
    }

    enum FlipType {
        case top
        case bottom

        /// Which edge of the full card to keep when cropping to a half.
        var alignment: Alignment {
            switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }

        /// A half card is rounded on its outer edge and square where it meets the hinge.
        func shape(cornerRadius radius: CGFloat) -> UnevenRoundedRectangle {
            switch self {
            case .top:
                return UnevenRoundedRectangle(topLeadingRadius: radius, bottomLeadingRadius: 0,
                                              bottomTrailingRadius: 0, topTrailingRadius: radius)
            case .bottom:
                return UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: radius,
                                              bottomTrailingRadius: radius, topTrailingRadius: 0)
            }
        }
    }

    // MARK: - Private

    private let text: String
    private let type: FlipType
    private let fontSize: CGFloat
    private let tileSize: CGSize
    private let cornerRadius: CGFloat

}
