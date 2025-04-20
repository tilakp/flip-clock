import SwiftUI

struct ClockView: View {

    let viewModel = ClockViewModel()
    @State private var availableHeight: CGFloat = 200

    var body: some View {
        GeometryReader { geometry in
            let minDimension = min(geometry.size.width / 6.5, geometry.size.height)
            let fontSize = minDimension * 0.8
            let digitWidth = fontSize * 0.38
            let digitHeight = fontSize * 0.5
            HStack(spacing: fontSize * 0.2) {
                HStack(spacing: fontSize * 0.07) {
                    FlipView(viewModel: viewModel.flipViewModels[0], fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                    FlipView(viewModel: viewModel.flipViewModels[1], fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                }
                Text(":")
                    .font(.system(size: fontSize * 0.8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: fontSize * 0.5)
                HStack(spacing: fontSize * 0.07) {
                    FlipView(viewModel: viewModel.flipViewModels[2], fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                    FlipView(viewModel: viewModel.flipViewModels[3], fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                }
                Text(":")
                    .font(.system(size: fontSize * 0.8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: fontSize * 0.5)
                HStack(spacing: fontSize * 0.07) {
                    FlipView(viewModel: viewModel.flipViewModels[4], fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                    FlipView(viewModel: viewModel.flipViewModels[5], fontSize: fontSize, digitWidth: digitWidth, digitHeight: digitHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}
