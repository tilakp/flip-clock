import Foundation
import AVFoundation

struct Alarm: Identifiable, Codable, Equatable {
    let id: UUID
    let time: Date
    var enabled: Bool
}

class AlarmManager: ObservableObject {
    @Published var alarms: [Alarm] = []
    private var timer: Timer?
    private var player: AVAudioPlayer?

    init() {
        loadAlarms()
        startTimer()
    }

    func addAlarm(time: Date) {
        let alarm = Alarm(id: UUID(), time: time, enabled: true)
        alarms.append(alarm)
        saveAlarms()
    }
    
    func removeAlarm(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        saveAlarms()
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        if let idx = alarms.firstIndex(of: alarm) {
            alarms[idx].enabled.toggle()
            saveAlarms()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkAlarms()
        }
    }
    
    private func checkAlarms() {
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        for alarm in alarms where alarm.enabled {
            let alarmComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            if now.hour == alarmComponents.hour && now.minute == alarmComponents.minute {
                playAlarmSound()
                toggleAlarm(alarm) // auto-disable after firing
            }
        }
    }
    
    private func playAlarmSound() {
        guard let url = Bundle.main.url(forResource: "retro_beep", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = 2
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
