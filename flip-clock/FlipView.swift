import SwiftUI

struct FlipView: View {

    init(viewModel: FlipViewModel, fontSize: CGFloat, tileSize: CGSize) {
        self.viewModel = viewModel
        self.fontSize = fontSize
        self.tileSize = tileSize
    }

    @ObservedObject var viewModel: FlipViewModel
    var fontSize: CGFloat
    var tileSize: CGSize

    var body: some View {
        let radius = FlipMetrics.cornerRadius(fontSize: fontSize)
        VStack(spacing: 0) {
            // The new top is already in place; the old top is the leaf that falls away from it.
            ZStack {
                half(viewModel.newValue, .top, radius)
                half(viewModel.oldValue, .top, radius)
                    .modifier(FlipLeaf(progress: viewModel.topProgress, type: .top, cornerRadius: radius))
            }
            // Width must be pinned. Color has no intrinsic width, and inside a fixedSize VStack
            // it draws to the width it was proposed rather than the stack's, painting the
            // hairline straight across the whole row of digits.
            Color.separator
                .frame(width: tileSize.width, height: FlipMetrics.separatorHeight)
            // The old bottom stays until the new bottom swings down over it.
            ZStack {
                half(viewModel.oldValue, .bottom, radius)
                half(viewModel.newValue, .bottom, radius)
                    .modifier(FlipLeaf(progress: viewModel.bottomProgress, type: .bottom, cornerRadius: radius))
            }
        }
        .fixedSize()
    }

    // MARK: - Private

    private func half(_ text: String?, _ type: SingleFlipView.FlipType, _ radius: CGFloat) -> some View {
        SingleFlipView(text: text ?? "", type: type, fontSize: fontSize,
                       tileSize: tileSize, cornerRadius: radius)
    }

}

/// A flip leaf in motion.
///
/// Rotation and shading are both derived from a single animatable value, so the leaf darkens
/// exactly as far as it has turned. Animating an opacity separately would have it fade on its own
/// schedule instead of tracking the angle, which is what gives a flat, decal-like look.
private struct FlipLeaf: ViewModifier, Animatable {

    var progress: Double
    let type: SingleFlipView.FlipType
    let cornerRadius: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .overlay(type.shape(cornerRadius: cornerRadius).fill(shading))
            .rotation3DEffect(.degrees(angle),
                              axis: (1, 0, 0),
                              anchor: type == .top ? .bottom : .top,
                              perspective: FlipMetrics.flipPerspective)
            // A perspective transform is singular edge-on: at exactly +/-90 the projection
            // diverges and smears a hairline clear across the window. A leaf that close to
            // edge-on has no face left to show, so drop it for those few degrees. The fallen
            // top leaf rests at -90, which is why that line was there the whole time.
            .opacity(abs(angle) > Self.edgeOnAngle ? 0 : 1)
    }

    private static let edgeOnAngle: Double = 87

    /// The old top leaf falls away toward the hinge; the new bottom leaf carries on down into place.
    private var angle: Double {
        switch type {
        case .top:
            return -90 * progress
        case .bottom:
            return 90 * (1 - progress)
        }
    }

    /// Lambert-ish: a leaf edge-on to the light catches the least of it. The gradient keeps the
    /// far edge fractionally brighter, as a real leaf tilting under a light is.
    private var shading: LinearGradient {
        let shade = min(max(1 - cos(angle * .pi / 180), 0), 1) * FlipMetrics.leafMaxShade
        return LinearGradient(colors: [.black.opacity(shade * 0.65), .black.opacity(shade)],
                              startPoint: type == .top ? .top : .bottom,
                              endPoint: type == .top ? .bottom : .top)
    }

}
