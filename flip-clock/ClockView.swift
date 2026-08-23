import SwiftUI

struct ClockView: View {

    let showSeconds: Bool

    var body: some View {
        GeometryReader { geometry in
            let groups = showSeconds ? 3 : 2
            let fontSize = FlipMetrics.fontSize(fitting: geometry.size, groups: groups)
            let tileSize = FlipMetrics.tileSize(fontSize: fontSize)
            HStack(spacing: fontSize * FlipMetrics.groupSpacing) {
                digitPair(startingAt: 0, fontSize: fontSize, tileSize: tileSize)
                colon(fontSize: fontSize)
                digitPair(startingAt: 2, fontSize: fontSize, tileSize: tileSize)
                if showSeconds {
                    colon(fontSize: fontSize)
                    digitPair(startingAt: 4, fontSize: fontSize, tileSize: tileSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { viewModel.showSeconds = showSeconds }
        .onChange(of: showSeconds) { _, newValue in viewModel.showSeconds = newValue }
    }

    // MARK: - Private

    @StateObject private var viewModel = ClockViewModel()

    private func digitPair(startingAt index: Int, fontSize: CGFloat, tileSize: CGSize) -> some View {
        HStack(spacing: fontSize * FlipMetrics.pairSpacing) {
            ForEach(index...index + 1, id: \.self) { offset in
                FlipView(viewModel: viewModel.flipViewModels[offset],
                         fontSize: fontSize,
                         tileSize: tileSize)
            }
        }
    }

    private func colon(fontSize: CGFloat) -> some View {
        let diameter = fontSize * FlipMetrics.colonDotDiameter
        return VStack(spacing: fontSize * FlipMetrics.colonDotGap) {
            Circle().fill(Color.white).frame(width: diameter, height: diameter)
            Circle().fill(Color.white).frame(width: diameter, height: diameter)
        }
        .frame(width: fontSize * FlipMetrics.colonWidth)
    }

}
