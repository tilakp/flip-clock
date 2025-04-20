import SwiftUI

struct SingleFlipView: View {

    init(text: String, type: FlipType, fontSize: CGFloat, digitWidth: CGFloat, digitHeight: CGFloat) {
        self.text = text
        self.type = type
        self.fontSize = fontSize
        self.digitWidth = digitWidth
        self.digitHeight = digitHeight
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .fontWeight(.heavy)
            .foregroundColor(.textColor)
            .fixedSize()
            .padding(type.padding, -fontSize/2)
            .frame(width: digitWidth, height: digitHeight, alignment: type.alignment)
            .padding(type.paddingEdges, fontSize/4)
            .clipped()
            .background(Color.flipBackground)
            .cornerRadius(4)
            .padding(type.padding, -fontSize/9)
            .clipped()
    }

    enum FlipType {
        case top
        case bottom

        var padding: Edge.Set {
            switch self {
            case .top:
                return .bottom
            case .bottom:
                return .top
            }
        }

        var paddingEdges: Edge.Set {
            switch self {
            case .top:
                return [.top, .leading, .trailing]
            case .bottom:
                return [.bottom, .leading, .trailing]
            }
        }

        var alignment: Alignment {
            switch self {
            case .top:
                return .bottom
            case .bottom:
                return .top
            }
        }

    }

    // MARK: - Private

    private let text: String
    private let type: FlipType
    private let fontSize: CGFloat
    private let digitWidth: CGFloat
    private let digitHeight: CGFloat

}
