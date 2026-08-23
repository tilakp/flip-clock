import Foundation
import Combine

final class ClockViewModel: ObservableObject {

    init() {
        ticker.start()
    }

    private(set) lazy var flipViewModels = { (0...5).map { _ in FlipViewModel() } }()

    /// When false the clock shows HH:MM and the ticker drops to one tick per minute.
    var showSeconds: Bool = true {
        didSet {
            guard showSeconds != oldValue else { return }
            ticker.interval = showSeconds ? 1 : 60
            setTimeInViewModels(at: Date())
        }
    }

    // MARK: - Private

    private lazy var ticker = TimeTicker(interval: 1) { [weak self] date in
        self?.setTimeInViewModels(at: date)
    }

    private func setTimeInViewModels(at date: Date) {
        let formatter = showSeconds ? DateFormatter.timeFormatter : .timeFormatterNoSeconds
        // Only the leading four view models are rendered when seconds are hidden, and zip stops
        // at the shorter sequence.
        zip(formatter.string(from: date), flipViewModels).forEach { number, viewModel in
            viewModel.text = "\(number)"
        }
    }

}
