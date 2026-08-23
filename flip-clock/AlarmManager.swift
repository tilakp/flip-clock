import Foundation
import AVFoundation

struct Alarm: Identifiable, Codable, Equatable {
    let id: UUID
    let time: Date
    var enabled: Bool
}

final class AlarmManager: ObservableObject {

    @Published private(set) var alarms: [Alarm] = []

    /// Non-nil while an alarm is sounding, so the UI can show the dismiss/snooze banner.
    @Published private(set) var ringingAlarm: Alarm?

    static let snoozeMinutes = 9

    init() {
        loadAlarms()
        ticker.start()
    }

    func addAlarm(time: Date) {
        alarms.append(Alarm(id: UUID(), time: time, enabled: true))
        saveAlarms()
    }

    func removeAlarm(_ alarm: Alarm) {
        if ringingAlarm?.id == alarm.id { silence() }
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }

    func toggleAlarm(_ alarm: Alarm) {
        setEnabled(!alarm.enabled, for: alarm.id)
    }

    /// Stop the sound and clear the ringing state.
    func silence() {
        autoSilence?.cancel()
        autoSilence = nil
        player?.stop()
        player = nil
        ringingAlarm = nil
    }

    /// Silence the current alarm and add a fresh one `snoozeMinutes` from now.
    func snooze() {
        silence()
        addAlarm(time: Date().addingTimeInterval(TimeInterval(Self.snoozeMinutes * 60)))
    }

    // MARK: - Private

    /// How long a untouched alarm keeps beeping before it gives up.
    private static let autoSilenceAfter: TimeInterval = 60

    private lazy var ticker = TimeTicker(interval: 1) { [weak self] date in
        self?.checkAlarms(at: date)
    }
    private var player: AVAudioPlayer?
    private var autoSilence: DispatchWorkItem?
    /// Alarm id to the minute it last fired in, so re-enabling an alarm inside its own matching
    /// minute doesn't set it off again immediately.
    private var lastFiredMinute: [UUID: Int] = [:]

    private func checkAlarms(at date: Date) {
        let minute = Int(floor(date.timeIntervalSinceReferenceDate / 60))
        let now = Calendar.current.dateComponents([.hour, .minute], from: date)
        for alarm in alarms where alarm.enabled {
            let alarmComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            guard now.hour == alarmComponents.hour, now.minute == alarmComponents.minute else { continue }
            guard lastFiredMinute[alarm.id] != minute else { continue }
            lastFiredMinute[alarm.id] = minute
            fire(alarm)
        }
    }

    private func fire(_ alarm: Alarm) {
        ringingAlarm = alarm
        setEnabled(false, for: alarm.id) // auto-disable after firing
        playAlarmSound()

        let work = DispatchWorkItem { [weak self] in self?.silence() }
        autoSilence?.cancel()
        autoSilence = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.autoSilenceAfter, execute: work)
    }

    private func setEnabled(_ enabled: Bool, for id: UUID) {
        guard let index = alarms.firstIndex(where: { $0.id == id }) else { return }
        guard alarms[index].enabled != enabled else { return }
        alarms[index].enabled = enabled
        saveAlarms()
    }

    private func playAlarmSound() {
        guard let url = Bundle.main.url(forResource: "retro_beep", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // until silenced, dismissed, or the auto-silence fires
            player?.play()
        } catch {
            print("Failed to play alarm sound: \(error)")
        }
    }

    private func saveAlarms() {
        if let data = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(data, forKey: "alarms")
        }
    }

    private func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: "alarms"),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            alarms = decoded
        }
    }

}
