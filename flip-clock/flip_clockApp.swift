//
//  flip_clockApp.swift
//  flip-clock
//
//  Created by Tilak Patel on 4/19/25.
//

import SwiftUI

@main
struct flip_clockApp: App {
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
