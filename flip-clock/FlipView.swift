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
        VStack(spacing: 0) {
            ZStack {
                SingleFlipView(text: viewModel.newValue ?? "", type: .top, fontSize: fontSize, tileSize: tileSize)
                SingleFlipView(text: viewModel.oldValue ?? "", type: .top, fontSize: fontSize, tileSize: tileSize)
                    .rotation3DEffect(.init(degrees: self.viewModel.animateTop ? -90 : .zero),
                                      axis: (1, 0, 0),
                                      anchor: .bottom,
                                      perspective: 0.5)
            }
            Color.separator
                .frame(height: FlipMetrics.separatorHeight)
            ZStack {
                SingleFlipView(text: viewModel.oldValue ?? "", type: .bottom, fontSize: fontSize, tileSize: tileSize)
                SingleFlipView(text: viewModel.newValue ?? "", type: .bottom, fontSize: fontSize, tileSize: tileSize)
                    .rotation3DEffect(.init(degrees: self.viewModel.animateBottom ? .zero : 90),
                                      axis: (1, 0, 0),
                                      anchor: .top,
                                      perspective: 0.5)
            }
        }
            .fixedSize()
    }

}
