import SwiftUI

/// One half of a flip card.
///
/// The whole card is drawn and then cropped to the requested half. Deriving both halves from the
/// same full-size card is what keeps a digit in register across the split: the previous approach
/// selected each half with its own chain of negative paddings, which dropped a thin band of the
/// glyph's middle and left strokes that cross the split visibly offset.
struct SingleFlipView: View {

    init(text: String, type: FlipType, fontSize: CGFloat, tileSize: CGSize) {
        self.text = text
        self.type = type
        self.fontSize = fontSize
        self.tileSize = tileSize
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .fontWeight(.heavy)
            .foregroundColor(.textColor)
            .fixedSize()
            .frame(width: tileSize.width, height: tileSize.height)
            .background(Color.flipBackground)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .frame(height: tileSize.height / 2, alignment: type.alignment)
            .clipped()
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
    }

    // MARK: - Private

    private let text: String
    private let type: FlipType
    private let fontSize: CGFloat
    private let tileSize: CGSize

}
