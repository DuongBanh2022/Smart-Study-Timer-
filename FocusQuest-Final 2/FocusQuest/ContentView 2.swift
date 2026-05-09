import SwiftUI
import Combine
import UserNotifications
import AVFoundation

struct ContentView: View {
    
    // MARK: - Timer Settings
    @State private var pomodoroLength = 25
    @State private var shortBreakLength = 5
    @State private var longBreakLength = 15
    
    // MARK: - Timer State
    @State private var timeRemaining = 25 * 60
    @State private var totalTime = 25 * 60
    @State private var timerRunning = false
    @State private var currentMode = "Pomodoro"
    
    // MARK: - XP
    @State private var xp = 0
    
    // MARK: - Loop
    @State private var isLooping = false
    @State private var loopStep = 0
    @State private var loopPhase = "Pomodoro"
    
    // MARK: - Navigation
    @State private var showingCustomSettings = false
    @State private var showingStats = false
    
    // MARK: - Stats
    @State private var sessionsCompleted = 0
    @State private var streak = 0
    
    // MARK: - Sound
    @State private var audioPlayer: AVAudioPlayer?
    
    // MARK: - GIF STATE
    @State private var currentGIF = "idle"
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            
            Image("FoggyForest")
                .resizable()
                .scaledToFill()
                .blur(radius: 6)
                .ignoresSafeArea()
            
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // MODE BUTTONS
                HStack {
                    modeButton("Pomodoro")
                    modeButton("Short Break")
                    modeButton("Long Break")
                    modeButton("Loop")
                }
                
                Button("Custom Timer") {
                    showingCustomSettings = true
                }
                
                Button("View Stats") {
                    showingStats = true
                }
                
                Text("XP: \(xp)")
                    .foregroundColor(.white)
                
                Text(currentMode)
                    .font(.title)
                    .foregroundColor(.white)
                
                // =========================
                // GIF LEFT + TIMER + GIF RIGHT
                // =========================
                HStack(spacing: 25) {
                    
                    // LEFT GIF
                    GIFView(gifName: currentGIF)
                        .frame(width: 500, height: 500)
                        .clipped()
                    
                    // TIMER
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(totalTime))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 34, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .frame(width: 160, height: 160)
                    
                    // RIGHT GIF
                    GIFView(gifName: currentGIF)
                        .frame(width: 500, height: 500)
                        .clipped()
                }
                
                // CONTROLS
                HStack {
                    Button {
                        timerRunning.toggle()
                        
                        if timerRunning {
                            currentGIF = "idle"
                        }
                    } label: {
                        Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                    }
                    
                    Button {
                        resetTimer()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding()
        }
        
        // =========================
        // TIMER LOGIC
        // =========================
        .onReceive(timer) { _ in
            guard timerRunning else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                
                timerRunning = false
                currentGIF = "complete"
                
                playSound(for: currentMode)
                sendNotification()
                
                if (!isLooping && currentMode == "Pomodoro") ||
                    (isLooping && loopPhase == "Pomodoro") {
                    
                    xp += 25
                    sessionsCompleted += 1
                    streak += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if isLooping {
                        nextLoopStep()
                    } else {
                        currentGIF = "idle"
                    }
                }
            }
        }
        
        // =========================
        // SHEETS
        // =========================
        .sheet(isPresented: $showingCustomSettings) {
            CustomSettingsView(
                pomodoroLength: $pomodoroLength,
                shortBreakLength: $shortBreakLength,
                longBreakLength: $longBreakLength,
                onSave: { resetTimer() }
            )
        }
        
        .sheet(isPresented: $showingStats) {
            StatsView(
                xp: xp,
                sessions: sessionsCompleted,
                streak: streak
            )
        }
        
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    // MARK: - MODE BUTTON
    func modeButton(_ title: String) -> some View {
        Button(title) {
            isLooping = false
            
            switch title {
            case "Pomodoro":
                switchMode("Pomodoro", duration: pomodoroLength)
            case "Short Break":
                switchMode("Short Break", duration: shortBreakLength)
            case "Long Break":
                switchMode("Long Break", duration: longBreakLength)
            case "Loop":
                isLooping = true
                startLoop()
            default:
                break
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(currentMode == title ? Color.blue : Color.gray.opacity(0.2))
        .foregroundColor(currentMode == title ? .white : .black)
        .clipShape(Capsule())
    }
    
    // MARK: - MODE LOGIC
    func switchMode(_ mode: String, duration: Int) {
        currentMode = mode
        timerRunning = false
        timeRemaining = duration * 60
        totalTime = duration * 60
        currentGIF = "idle"
    }
    
    func resetTimer() {
        timerRunning = false
        
        switch currentMode {
        case "Pomodoro":
            timeRemaining = pomodoroLength * 60
            totalTime = pomodoroLength * 60
            
        case "Short Break":
            timeRemaining = shortBreakLength * 60
            totalTime = shortBreakLength * 60
            
        case "Long Break":
            timeRemaining = longBreakLength * 60
            totalTime = longBreakLength * 60
            
        case "Loop":
            if loopPhase == "Pomodoro" {
                timeRemaining = pomodoroLength * 60
                totalTime = pomodoroLength * 60
            } else if loopPhase == "Short Break" {
                timeRemaining = shortBreakLength * 60
                totalTime = shortBreakLength * 60
            } else {
                timeRemaining = longBreakLength * 60
                totalTime = longBreakLength * 60
            }
            
        default:
            break
        }
        
        currentGIF = "idle"
    }
    func startLoop() {
        loopStep = 1
        loopPhase = "Pomodoro"
        currentMode = "Loop"
        timeRemaining = pomodoroLength * 60
        totalTime = pomodoroLength * 60
        timerRunning = true
        currentGIF = "idle"
    }
    
    func nextLoopStep() {
        if loopPhase == "Pomodoro" {
            loopPhase = "Short Break"
            timeRemaining = shortBreakLength * 60
        } else {
            loopPhase = "Pomodoro"
            loopStep += 1
            timeRemaining = pomodoroLength * 60
        }
        
        timerRunning = true
        currentGIF = "idle"
    }
    
    // MARK: - UTIL
    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    // MARK: - SOUND
    func playSound(for mode: String) {
        let name = "pomodoro"
        
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }
    
    // MARK: - NOTIFICATION
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Done!"
        content.body = "Session finished"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
