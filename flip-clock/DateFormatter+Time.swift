import Foundation

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hhmmss" // 12-hour format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
