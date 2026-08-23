import Foundation

extension DateFormatter {
    /// 12-hour HHMMSS, one character per flip tile.
    static let timeFormatter: DateFormatter = digitsFormatter(format: "hhmmss")

    /// 12-hour HHMM, for when seconds are hidden.
    static let timeFormatterNoSeconds: DateFormatter = digitsFormatter(format: "hhmm")

    private static func digitsFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
