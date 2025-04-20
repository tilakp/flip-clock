import SwiftUI

struct ContentView: View {
    @StateObject private var alarmManager = AlarmManager()
    @State private var showingAlarmSheet = false
    @State private var newAlarmTime = Date()
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    ClockView()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingAlarmSheet = true
                        }
                    Spacer()
                    if !alarmManager.alarms.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(alarmManager.alarms) { alarm in
                                    HStack(spacing: 8) {
                                        Text(alarm.time, style: .time)
                                            .foregroundColor(alarm.enabled ? .white : .gray)
                                            .font(.system(size: 14, design: .monospaced))
                                        Button(action: { alarmManager.toggleAlarm(alarm) }) {
                                            Image(systemName: alarm.enabled ? "bell.fill" : "bell.slash")
                                                .foregroundColor(alarm.enabled ? .green : .gray)
                                        }
                                        Button(action: { alarmManager.removeAlarm(alarm) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .sheet(isPresented: $showingAlarmSheet) {
                    VStack(spacing: 24) {
                        Text("Add Alarm")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("Alarm Time", selection: $newAlarmTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(FieldDatePickerStyle())
                            .labelsHidden()
                            .colorScheme(.dark)
                        Button("Add") {
                            alarmManager.addAlarm(time: newAlarmTime)
                            showingAlarmSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        Button("Cancel") {
                            showingAlarmSheet = false
                        }
                        .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(Color.black)
                }
                AppWindowAccessor { window in
                    if let window = window {
                        window.titlebarAppearsTransparent = true
                        window.backgroundColor = NSColor.black
                        window.titleVisibility = .hidden
                        window.isOpaque = false
                        window.standardWindowButton(.closeButton)?.isHidden = false
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
                        window.standardWindowButton(.zoomButton)?.isHidden = false
                        window.styleMask.insert(.titled)
                        window.styleMask.insert(.fullSizeContentView)
                    }
                }
                .frame(width: 0, height: 0)
            }
        }
        .environmentObject(alarmManager)
    }
}

#Preview {
    ContentView()
}
