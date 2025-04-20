# Flip Clock for macOS

A beautiful, resizable, retro-inspired flip clock app for macOS, built with SwiftUI. The app features smooth flip animations, a fully responsive UI, and a built-in alarm system with retro beep sounds.

---

## Features

- **Retro Flip Animation:**
  - Digits flip smoothly, mimicking classic mechanical flip clocks.
- **Fully Responsive:**
  - The clock resizes dynamically to fit any window size or aspect ratio.
- **Dark Mode by Default:**
  - The app always launches in dark mode for a classic look.
- **Seamless Black UI:**
  - The entire window, including the title bar, is black for a distraction-free experience.
- **Alarm Support:**
  - Click anywhere on the clock to add a new alarm.
  - Add multiple alarms, enable/disable, and delete them easily.
  - Alarms trigger a retro-style beep sound.

---

## How to Use

1. **Run the app.**
2. **Resize** the window to your liking—the clock and digits will always fit perfectly.
3. **Add alarms** by clicking anywhere on the clock display. Set the time and save.
4. **Manage alarms** in the horizontal list below the clock. Enable/disable or delete as needed.
5. When an alarm goes off, you'll hear a retro beep sound.

---

## Code Structure & Explanation

- **SwiftUI-Based:**
  - The UI is built using SwiftUI for declarative, modern, and responsive design.
- **Key Files:**
  - `ContentView.swift`: Main entry point, manages layout, alarm sheet, and window appearance.
  - `ClockView.swift`: Contains the flip clock layout and handles responsive sizing.
  - `FlipView.swift` & `SingleFlipView.swift`: Implement the flip animation for each digit.
  - `AlarmManager.swift`: ObservableObject managing alarms, persistence, and sound playback.
  - `AppWindowAccessor.swift`: Allows customization of the NSWindow (title bar, background, etc).
  - `Color+Flip.swift`: Centralizes color definitions for easy theme changes.
  - `retro_beep.wav`: The retro alarm sound (replaceable with any WAV file).
- **Alarm Logic:**
  - Alarms are stored in UserDefaults for persistence.
  - When the system time matches an enabled alarm, the sound plays and the alarm auto-disables.
- **Customization:**
  - All colors and fonts are easily adjustable in `Color+Flip.swift` and the relevant views.
  - The app enforces dark mode and a seamless black UI.

---

## Requirements

- macOS 12.0+
- Xcode 14+

---

## Customization & Extensibility

- **Change Alarm Sound:**
  - Replace `retro_beep.wav` in the project directory with your own WAV file.
- **Digit Colors:**
  - Edit `Color+Flip.swift` to change digit or background colors.
- **Add Features:**
  - The modular codebase makes it easy to add features like AM/PM display, snooze, or custom themes.

---

## Credits
- Retro beep sound from [freesound.org](https://freesound.org/people/Soundholder/sounds/425331/) (Creative Commons 0).

---

## License
MIT License
