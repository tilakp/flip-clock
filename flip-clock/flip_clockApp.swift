//
//  flip_clockApp.swift
//  flip-clock
//
//  Created by Tilak Patel on 4/19/25.
//

import SwiftUI

@main
struct flip_clockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        for window in NSApplication.shared.windows {
            window.titlebarAppearsTransparent = true
            window.backgroundColor = NSColor.black
            window.titleVisibility = .hidden
        }
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window.titlebarAppearsTransparent = true
                        window.backgroundColor = NSColor.black
                        window.titleVisibility = .hidden
                    }
                }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var timer: Timer?
    var didSetInitialIcon = false
    func applicationDidFinishLaunching(_ notification: Notification) {
        setDefaultDockIconIfNeeded()
        updateDockIcon()
        scheduleMinuteSyncTimer()
    }
    func setDefaultDockIconIfNeeded() {
        guard !didSetInitialIcon else { return }
        if let url = Bundle.main.url(forResource: "clock_default", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            NSApp.applicationIconImage = image
            didSetInitialIcon = true
        }
    }
    func scheduleMinuteSyncTimer() {
        timer?.invalidate()
        let now = Date()
        let calendar = Calendar.current
        let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .nextTime) ?? now.addingTimeInterval(60)
        let interval = nextMinute.timeIntervalSince(now)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.updateDockIcon()
            self?.startRepeatingMinuteTimer()
        }
    }
    func startRepeatingMinuteTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateDockIcon()
        }
    }
    func updateDockIcon() {
        let image = FlipClockDockIconRenderer.renderCurrentTimeIcon()
        NSApp.applicationIconImage = image
    }
}

struct FlipClockDockIconRenderer {
    static func renderCurrentTimeIcon() -> NSImage {
        let size = NSSize(width: 256, height: 256)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.black.setFill()
        let roundedRect = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: 48, yRadius: 48)
        roundedRect.fill()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        // Use a smaller font size and tighter rect for better fit
        let font = NSFont.monospacedDigitSystemFont(ofSize: 80, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let timeString = formatter.string(from: Date())
        let rect = NSRect(x: 0, y: 78, width: size.width, height: 100)
        (timeString as NSString).draw(in: rect, withAttributes: attrs)
        image.unlockFocus()
        return image
    }
}
