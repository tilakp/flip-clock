import SwiftUI

struct FlipView: View {

    init(viewModel: FlipViewModel, fontSize: CGFloat, digitWidth: CGFloat, digitHeight: CGFloat) {
        self.viewModel = viewModel
        self.fontSize = fontSize
        self.digitWidth = digitWidth
        self.digitHeight = digitHeight
    }

    @ObservedObject var viewModel: FlipViewModel
    var fontSize: CGFloat
    var digitWidth: CGFloat
    var digitHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SingleFlipView(text: viewModel.newValue ?? "", type: .top, fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                SingleFlipView(text: viewModel.oldValue ?? "", type: .top, fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                    .rotation3DEffect(.init(degrees: self.viewModel.animateTop ? -90 : .zero),
                                      axis: (1, 0, 0),
                                      anchor: .bottom,
                                      perspective: 0.5)
            }
            Color.separator
                .frame(height: 1)
            ZStack {
                SingleFlipView(text: viewModel.oldValue ?? "", type: .bottom, fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                SingleFlipView(text: viewModel.newValue ?? "", type: .bottom, fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                    .rotation3DEffect(.init(degrees: self.viewModel.animateBottom ? .zero : 90),
                                      axis: (1, 0, 0),
                                      anchor: .top,
                                      perspective: 0.5)
            }
        }
            .fixedSize()
    }

}
