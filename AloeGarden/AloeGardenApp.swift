import SwiftUI
import Combine
import WidgetKit

// MARK: - App entry

@main
struct AloeGardenApp: App {
    init() {
        #if DEBUG
        ReadingData.seedSampleDataIfNeeded()
        #endif
    }

    var body: some Scene {
        WindowGroup { RootView() }
    }
}

struct RootView: View {
    @AppStorage("didOnboard") private var didOnboard = false
    @State private var ready = false
    @State private var shouldStartSession = false
    
    var body: some View {
        Group {
            if !ready {
                LaunchView { withAnimation(.easeInOut(duration: 0.5)) { ready = true } }
                    .transition(.opacity)
            } else if didOnboard {
                GartenView(shouldStartSession: $shouldStartSession)
                    .transition(.opacity)
            } else {
                OnboardingView { didOnboard = true }.transition(.opacity)
            }
        }
        .onOpenURL { url in
            // Handle the widget deep link
            if url.scheme == "aloegarden", url.host == "startSession" {
                shouldStartSession = true
            }
        }
    }
}

// MARK: - Color & gradient tokens

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: alpha)
    }
}

extension Color {
    static let cream   = Color(hex: 0xEFE6D4)
    static let ink     = Color(hex: 0x2B3326)
    static let muted   = Color(hex: 0x908872)
    static let forest  = Color(hex: 0x36492F)
    static let clay    = Color(hex: 0xBE6B45)
    static let sand    = Color(hex: 0xE5D9C0)
    static let surface = Color(hex: 0xFBF6EC)
    
    // Dark mode colors
    static let darkBg      = Color(hex: 0x0F1410)
    static let darkSurface = Color(hex: 0x1A1F1B)
    static let darkText    = Color(hex: 0xE8E4D8)
    static let darkMuted   = Color(hex: 0x9A9580)
}

private let leafGradient = LinearGradient(colors: [Color(hex: 0x5E7350), Color(hex: 0xA9BB86)], startPoint: .bottom, endPoint: .top)
private let leafHiGradient = LinearGradient(colors: [Color(hex: 0x7E9466), Color(hex: 0xC8D4AB)], startPoint: .bottom, endPoint: .top)
private let potGradient = LinearGradient(colors: [Color(hex: 0xCC7C54), Color(hex: 0x9C5230)], startPoint: .top, endPoint: .bottom)
private let rimGradient = LinearGradient(colors: [Color(hex: 0xDC9469), Color(hex: 0xC0734B)], startPoint: .top, endPoint: .bottom)
private let soilGradient = LinearGradient(colors: [Color(hex: 0x5C3E27), Color(hex: 0x3E2917)], startPoint: .top, endPoint: .bottom)
private let bloomGradient = LinearGradient(colors: [Color(hex: 0xE48A47), Color(hex: 0xC25A2E)], startPoint: .top, endPoint: .bottom)

// MARK: - Plant shapes

struct Leaf: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path(); let w = r.width, h = r.height
        let cx = w / 2, sx = w / 18, sy = h / 100
        p.move(to: CGPoint(x: cx, y: h))
        p.addCurve(to: CGPoint(x: cx, y: 0),
                   control1: CGPoint(x: cx - 8 * sx, y: h - 32 * sy),
                   control2: CGPoint(x: cx - 9 * sx, y: h - 66 * sy))
        p.addCurve(to: CGPoint(x: cx, y: h),
                   control1: CGPoint(x: cx + 9 * sx, y: h - 66 * sy),
                   control2: CGPoint(x: cx + 8 * sx, y: h - 32 * sy))
        p.closeSubpath(); return p
    }
}

private struct LeafView: View {
    var length: CGFloat; var width: CGFloat
    var body: some View {
        ZStack {
            Leaf().fill(leafGradient)
            Leaf().scale(x: 0.4, y: 0.9, anchor: .center).fill(leafHiGradient).opacity(0.5)
        }
        .frame(width: width, height: length)
    }
}

struct AloeRosette: View {
    var length: CGFloat = 96
    var leafWidth: CGFloat = 18
    private let leaves: [(Double, CGFloat)] =
        [(-68, 0.70), (-50, 0.80), (-32, 0.90), (-15, 0.97), (0, 1.0),
         (15, 0.97), (32, 0.90), (50, 0.80), (68, 0.70)]
    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(0..<leaves.count, id: \.self) { i in
                LeafView(length: length * leaves[i].1, width: leafWidth * leaves[i].1)
                    .rotationEffect(.degrees(leaves[i].0), anchor: .bottom)
            }
        }
        .frame(width: length * 1.8, height: length, alignment: .bottom)
    }
}

private struct StemShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX - 1, y: r.maxY))
        p.addCurve(to: CGPoint(x: r.midX, y: r.minY),
                   control1: CGPoint(x: r.midX + 2, y: r.maxY * 0.6),
                   control2: CGPoint(x: r.midX - 2, y: r.maxY * 0.25))
        return p
    }
}

struct BloomSpike: View {
    var height: CGFloat = 150
    private var s: CGFloat { height / 150 }
    private let blossoms: [(CGFloat, CGFloat, CGFloat, CGFloat)] =
        [(-7, 118, 14, 22), (7, 130, 13, 20), (-6, 142, 12, 18),
         (6, 152, 10, 16), (-4, 162, 8, 14), (3, 170, 7, 11), (0, 176, 5, 8)]
    var body: some View {
        ZStack(alignment: .bottom) {
            StemShape().stroke(Color(hex: 0x7C8A58),
                               style: StrokeStyle(lineWidth: 5 * s, lineCap: .round))
                .frame(width: 24 * s, height: height)
            ForEach(0..<blossoms.count, id: \.self) { i in
                let b = blossoms[i]
                Ellipse().fill(bloomGradient).frame(width: b.2 * s, height: b.3 * s)
                    .offset(x: b.0 * s, y: -b.1 * s)
            }
        }
        .frame(width: 30 * s, height: height, alignment: .bottom)
    }
}

struct Sprout: View {
    var scale: CGFloat = 1
    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule().fill(Color(hex: 0x7E8B5C)).frame(width: 4 * scale, height: 24 * scale)
            Leaf().fill(leafGradient).frame(width: 22 * scale, height: 34 * scale)
                .rotationEffect(.degrees(-44), anchor: .bottom).offset(y: -6 * scale)
            Leaf().fill(leafGradient).frame(width: 22 * scale, height: 34 * scale)
                .rotationEffect(.degrees(44), anchor: .bottom).offset(y: -6 * scale)
        }
        .frame(width: 56 * scale, height: 46 * scale, alignment: .bottom)
    }
}

private struct PotBody: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height; var p = Path()
        p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w * 0.96, y: h * 0.9))
        p.addQuadCurve(to: CGPoint(x: w * 0.91, y: h), control: CGPoint(x: w * 0.95, y: h))
        p.addLine(to: CGPoint(x: w * 0.09, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.04, y: h * 0.9), control: CGPoint(x: w * 0.05, y: h))
        p.closeSubpath(); return p
    }
}

struct PotView: View {
    var width: CGFloat = 320
    private var bodyH: CGFloat { width * 0.29 }
    var body: some View {
        ZStack(alignment: .top) {
            PotBody().fill(potGradient).frame(width: width, height: bodyH)
            RoundedRectangle(cornerRadius: 8).fill(rimGradient)
                .frame(width: width + 20, height: 22).offset(y: -9)
            Ellipse().fill(soilGradient).frame(width: width * 0.49, height: 15).offset(y: -2)
        }
        .frame(width: width + 20, height: bodyH, alignment: .top)
    }
}

/// Composed garden illustration. `richness` 0…1 controls how full it looks.
struct GardenScene: View {
    var richness: Double = 1
    private let W: CGFloat = 358
    private let baseY: CGFloat = 176
    var body: some View {
        ZStack {
            Circle().fill(RadialGradient(
                colors: [Color(hex: 0xF6E2BE), Color(hex: 0xF6E2BE, alpha: 0)],
                center: .center, startRadius: 4, endRadius: 44))
                .frame(width: 88, height: 88).position(x: 305, y: 58)
            Circle().fill(Color(hex: 0xE7BE6C)).opacity(0.7)
                .frame(width: 32, height: 32).position(x: 305, y: 58)

            PotView(width: 320).position(x: W / 2, y: baseY + 320 * 0.29 / 2)

            Sprout(scale: 0.85).position(x: 46, y: baseY - 46 * 0.85 / 2)
            Sprout(scale: 0.78).position(x: 320, y: baseY - 46 * 0.78 / 2)
            AloeRosette(length: 58).position(x: 100, y: baseY - 29)
            AloeRosette(length: 78).position(x: 258, y: baseY - 39)

            ZStack(alignment: .bottom) {
                AloeRosette(length: 96)
                if richness > 0.5 { BloomSpike(height: 150) }
            }
            .frame(width: 180, height: 200, alignment: .bottom)
            .position(x: W / 2, y: baseY - 100)
        }
        .frame(width: W, height: 250)
    }
}

// MARK: - Shared bits

private struct StatCard: View {
    var icon: String, value: String, label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon).font(.system(size: 17, weight: .medium)).foregroundStyle(Color.clay)
            Text(value).font(.system(size: 25, design: .serif)).foregroundStyle(Color.darkText)
            Text(label).font(.system(size: 11.5)).foregroundStyle(Color.darkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15).padding(.horizontal, 12)
        .background(Color.darkSurface, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color(hex: 0x000000, alpha: 0.3), radius: 8, y: 5)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16.5, weight: .semibold))
            .frame(maxWidth: .infinity).padding(.vertical, 18)
            .foregroundStyle(Color(hex: 0xF4ECDB))
            .background(Color.forest, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: 0x36492F, alpha: 0.55), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Launch / loading screen

struct LaunchView: View {
    var onFinished: () -> Void
    @State private var grow = false
    @State private var bloom = false
    @State private var showText = false
    @State private var sway = false
    @State private var fill: CGFloat = 0

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0xF4ECDB), Color(hex: 0xECE1CD), Color(hex: 0xE6DAC3)],
                           center: UnitPoint(x: 0.5, y: 0.42), startRadius: 0, endRadius: 620)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // sun glow + growing aloe
                ZStack {
                    Circle().fill(RadialGradient(
                        colors: [Color(hex: 0xF6E2BE, alpha: showText ? 0.9 : 0), Color(hex: 0xF6E2BE, alpha: 0)],
                        center: .center, startRadius: 4, endRadius: 130))
                        .frame(width: 280, height: 280)
                        .animation(.easeOut(duration: 1.2), value: showText)

                    ZStack(alignment: .bottom) {
                        PotView(width: 150)
                        ZStack(alignment: .bottom) {
                            AloeRosette(length: 96)
                                .scaleEffect(grow ? 1 : 0.12, anchor: .bottom)
                                .opacity(grow ? 1 : 0)
                            BloomSpike(height: 150)
                                .scaleEffect(x: 1, y: bloom ? 1 : 0, anchor: .bottom)
                                .opacity(bloom ? 1 : 0)
                        }
                        .offset(y: -38)
                    }
                    .rotationEffect(.degrees(sway ? 1.2 : -1.2), anchor: .bottom)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: sway)
                }

                // wordmark
                VStack(spacing: 6) {
                    HStack(spacing: 9) {
                        Image(systemName: "leaf.fill").font(.system(size: 15)).foregroundStyle(Color.clay)
                        Text("Aloe Garden").font(.system(size: 30, design: .serif)).foregroundStyle(Color.ink)
                    }
                    Text("Lies dich in einen Garten").font(.system(size: 14)).foregroundStyle(Color.muted)
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 12)
                .animation(.easeOut(duration: 0.6), value: showText)
                .padding(.top, 28)

                Spacer()

                // sprouting progress bar
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0x2B3326, alpha: 0.12)).frame(width: 160, height: 6)
                    Capsule().fill(LinearGradient(colors: [Color(hex: 0x7E9A5C), Color.clay],
                                                  startPoint: .leading, endPoint: .trailing))
                        .frame(width: 160 * fill, height: 6)
                }
                .padding(.bottom, 54)
            }
        }
        .onAppear {
            sway = true
            withAnimation(.spring(response: 0.8, dampingFraction: 0.62)) { grow = true }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.45)) { bloom = true }
            withAnimation { showText = true }
            withAnimation(.easeInOut(duration: 1.9)) { fill = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { onFinished() }
        }
    }
}

// MARK: - Reading progress model

struct Progress {
    let totalSeconds: Double
    let sessionCount: Int
    let streak: Int
    var totalMinutes: Int { Int(totalSeconds / 60) }
    var level: Int { totalMinutes / 30 + 1 }
    var minutesInLevel: Int { totalMinutes % 30 }
    var fraction: Double { Double(minutesInLevel) / 30 }
    var hoursLabel: String {
        let h = totalMinutes / 60, m = totalMinutes % 60
        return h > 0 ? "\(h) Std \(m)" : "\(m) Min"
    }
}

// MARK: - Reading data store

/// A single completed reading session. Persisted so stats and streaks are real.
struct SessionRecord: Codable {
    let date: Date
    let seconds: Double
    var minutes: Int { Int(seconds / 60) }
}

/// Source of truth for reading progress, shared with the widget via the App Group.
/// Keeps the scalar keys (`totalSeconds`, `sessionCount`, `streak`) the widget reads
/// in sync with the underlying session log.
enum ReadingData {
    static let suiteName = "group.aloeGarden"
    private static var store: UserDefaults? { UserDefaults(suiteName: suiteName) }
    private static let sessionsKey = "sessions"

    static func loadSessions() -> [SessionRecord] {
        guard let data = store?.data(forKey: sessionsKey),
              let list = try? JSONDecoder().decode([SessionRecord].self, from: data)
        else { return [] }
        return list
    }

    /// Records a completed session, refreshes the derived totals and the widget,
    /// and returns the new totals so the UI can update immediately.
    @discardableResult
    static func record(seconds: Double, at date: Date = Date()) -> (totalSeconds: Double, sessionCount: Int, streak: Int) {
        var sessions = loadSessions()
        sessions.append(SessionRecord(date: date, seconds: seconds))
        if let data = try? JSONEncoder().encode(sessions) {
            store?.set(data, forKey: sessionsKey)
        }
        let totalSeconds = sessions.reduce(0) { $0 + $1.seconds }
        let count = sessions.count
        let streak = currentStreak(from: sessions)
        store?.set(totalSeconds, forKey: "totalSeconds")
        store?.set(count, forKey: "sessionCount")
        store?.set(streak, forKey: "streak")
        WidgetCenter.shared.reloadAllTimelines()
        return (totalSeconds, count, streak)
    }

    /// Consecutive days with at least one session, counting back from today
    /// (or yesterday, so a streak isn't "lost" before you've read today).
    static func currentStreak(from sessions: [SessionRecord]) -> Int {
        let cal = Calendar.current
        let days = Set(sessions.map { cal.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }
        var day = cal.startOfDay(for: Date())
        if !days.contains(day) {
            day = cal.date(byAdding: .day, value: -1, to: day)!
            if !days.contains(day) { return 0 }
        }
        var count = 0
        while days.contains(day) {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }

#if DEBUG
    /// Seeds sample sessions on Mon/Tue/Wed of the current week, once, when the log is
    /// empty — for testing the stats screen and widget. DEBUG-only; not shipped.
    static func seedSampleDataIfNeeded() {
        guard loadSessions().isEmpty else { return }
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let today = cal.startOfDay(for: Date())
        let monday = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let samples: [(dayOffset: Int, hour: Int, minutes: Double)] = [
            (0, 8, 24),   // Mo
            (1, 21, 18),  // Di
            (2, 19, 31),  // Mi
        ]
        for s in samples {
            let day = cal.date(byAdding: .day, value: s.dayOffset, to: monday)!
            let date = cal.date(bySettingHour: s.hour, minute: 0, second: 0, of: day) ?? day
            record(seconds: s.minutes * 60, at: date)
        }
    }
#endif
}

// MARK: - Onboarding

struct OnboardingView: View {
    var onStart: () -> Void
    @State private var sway = false
    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0xF4ECDB), Color(hex: 0xECE1CD), Color(hex: 0xE6DAC3)],
                           center: UnitPoint(x: 0.5, y: 0.04), startRadius: 0, endRadius: 640)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill").font(.system(size: 13)).foregroundStyle(Color.clay)
                    Text("ALOE GARDEN").font(.system(size: 14, design: .serif)).kerning(3)
                        .foregroundStyle(Color(hex: 0x7E8B5C))
                }
                .padding(.top, 16)

                Spacer(minLength: 0)
                ZStack(alignment: .bottom) {
                    PotView(width: 150).offset(y: 0)
                    ZStack(alignment: .bottom) { AloeRosette(length: 96); BloomSpike(height: 150) }
                        .offset(y: -38)
                }
                .rotationEffect(.degrees(sway ? 1.3 : -1.3), anchor: .bottom)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: sway)
                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Text("Lass deinen Garten\n\(Text("durch Lesen").italic().foregroundColor(.clay)) wachsen.")
                        .font(.system(size: 33, design: .serif))
                        .multilineTextAlignment(.center).foregroundStyle(Color.ink)
                    Text("Jede fokussierte Lese-Session pflanzt und nährt deinen Garten. Greifst du zwischendurch zum Handy, pausiert das Wachstum.")
                        .font(.system(size: 15)).foregroundStyle(Color(hex: 0x6B6553))
                        .multilineTextAlignment(.center).lineSpacing(3).frame(maxWidth: 300)
                }

                VStack(spacing: 13) {
                    feature("book.fill", "Fokussiert lesen, ganz ungestört.")
                    feature("leaf.fill", "Pflanzen wachsen mit jeder Minute.")
                    feature("lock.fill", "Ablenkung? Die Session zählt nicht.")
                }
                .padding(.vertical, 26)

                Button(action: onStart) {
                    HStack(spacing: 9) { Text("Garten anlegen"); Image(systemName: "arrow.right") }
                }
                .buttonStyle(PrimaryButtonStyle())

                HStack(spacing: 7) {
                    Capsule().fill(Color.clay).frame(width: 24, height: 7)
                    Circle().fill(Color(hex: 0xCFC1A1)).frame(width: 7, height: 7)
                    Circle().fill(Color(hex: 0xCFC1A1)).frame(width: 7, height: 7)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 30).padding(.bottom, 30)
        }
        .onAppear { sway = true }
    }
    private func feature(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(Color.clay)
                .frame(width: 38, height: 38).background(Color.sand, in: RoundedRectangle(cornerRadius: 11))
            Text(text).font(.system(size: 14.5)).foregroundStyle(Color(hex: 0x3C3A2E))
            Spacer()
        }
    }
}

// MARK: - Home (Garten)

struct GartenView: View {
    @AppStorage("totalSeconds", store: UserDefaults(suiteName: "group.aloeGarden")) 
    private var totalSeconds: Double = 0
    @AppStorage("sessionCount", store: UserDefaults(suiteName: "group.aloeGarden")) 
    private var sessionCount: Int = 0
    @AppStorage("streak", store: UserDefaults(suiteName: "group.aloeGarden")) 
    private var streak: Int = 0

    @State private var showFocus = false
    @State private var showReward = false
    @State private var showStats = false
    @State private var lastMinutes = 0
    @State private var sway = false
    
    @Binding var shouldStartSession: Bool

    private var p: Progress { Progress(totalSeconds: totalSeconds, sessionCount: sessionCount, streak: streak) }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "Guten Morgen"
        case 12..<18: return "Guten Tag"
        case 18..<22: return "Guten Abend"
        default:      return "Gute Nacht"
        }
    }

    init(shouldStartSession: Binding<Bool> = .constant(false)) {
        self._shouldStartSession = shouldStartSession
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(greeting).font(.system(size: 13)).foregroundStyle(Color.darkMuted)
                        Text("Dein Garten").font(.system(size: 28, design: .serif)).foregroundStyle(Color.darkText)
                    }
                    Spacer()
                    Button { showStats = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "leaf.fill").font(.system(size: 12))
                            Text("Level \(p.level)").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(Color(hex: 0x7E9A5C))
                        .padding(.vertical, 8).padding(.horizontal, 13)
                        .background(Color.darkSurface, in: Capsule())
                    }
                }
                .padding(.bottom, 20)

                gardenCard.padding(.bottom, 18)

                HStack(spacing: 11) {
                    StatCard(icon: "book.fill", value: "\(p.totalMinutes)", label: "Minuten")
                    StatCard(icon: "calendar", value: "\(sessionCount)", label: "Sessions")
                    StatCard(icon: "leaf.fill", value: "\(streak)", label: "Tage Serie")
                }
                .padding(.bottom, 18)
                
                Button { showFocus = true } label: {
                    HStack(spacing: 9) { Image(systemName: "book.fill"); Text("Lesen starten") }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 22).padding(.top, 12).padding(.bottom, 40)
        }
        .background(Color.darkBg.ignoresSafeArea())
        .onAppear { sway = true }
        .onChange(of: shouldStartSession) { _, newValue in
            if newValue {
                showFocus = true
                shouldStartSession = false
            }
        }
        .fullScreenCover(isPresented: $showFocus) {
            FocusSessionView { elapsed, completed in
                if completed {
                    let result = ReadingData.record(seconds: elapsed)
                    totalSeconds = result.totalSeconds
                    sessionCount = result.sessionCount
                    streak = result.streak
                    lastMinutes = Int(elapsed / 60)
                    showReward = true
                }
            }
        }
        .fullScreenCover(isPresented: $showReward) {
            RewardView(minutesAdded: lastMinutes, progress: p) { showReward = false }
        }
        .sheet(isPresented: $showStats) { StatistikView(progress: p) }
    }

    private var gardenCard: some View {
        VStack(spacing: 0) {
            GardenScene(richness: min(1, Double(p.level) / 3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30) // Add padding to prevent overlap
                .rotationEffect(.degrees(sway ? 1.3 : -1.3), anchor: .bottom)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: sway)
            VStack(spacing: 9) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Level \(p.level) · Wachsende Aloe").font(.system(size: 16, design: .serif)).foregroundStyle(Color.darkText)
                    Spacer()
                    Text("\(p.minutesInLevel) / 30 Min").font(.system(size: 12.5)).foregroundStyle(Color.darkMuted)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(hex: 0xFFFFFF, alpha: 0.1))
                        Capsule().fill(LinearGradient(colors: [Color(hex: 0x7E9A5C), Color.clay],
                                                      startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(9, geo.size.width * p.fraction))
                    }
                }
                .frame(height: 9)
            }
            .padding(.horizontal, 14).padding(.bottom, 16).padding(.top, 6)
        }
        .background(LinearGradient(colors: [Color(hex: 0x1F2B20), Color(hex: 0x1A231C)], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color(hex: 0xFFFFFF, alpha: 0.08)))
        .shadow(color: Color(hex: 0x000000, alpha: 0.4), radius: 18, y: 14)
    }
}

// MARK: - Focus session

struct FocusSessionView: View {
    var onFinish: (Double, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var startDate = Date()
    @State private var elapsed: Double = 0
    @State private var leftApp = false
    @State private var showQuitConfirm = false
    @State private var pulse = false
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var ringProgress: Double { min(elapsed / 1500, 1) }
    private var accent: Color { leftApp ? Color(hex: 0xC9584B) : Color(hex: 0xBE6B45) }
    private var glow: Color { leftApp ? Color(hex: 0xC9584B) : Color(hex: 0x96B874) }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: leftApp ? [Color(hex: 0x2A1C1A), Color(hex: 0x15100F), Color(hex: 0x0C0908)]
                                : [Color(hex: 0x1F2C22), Color(hex: 0x141C16), Color(hex: 0x0D130E)],
                center: UnitPoint(x: 0.5, y: 0.36), startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Text("FOKUS-SESSION").font(.system(size: 11.5, weight: .semibold)).kerning(2.4)
                    .foregroundStyle(leftApp ? accent : Color(hex: 0xA9BB86))
                    .padding(.vertical, 7).padding(.horizontal, 15)
                    .background(.white.opacity(0.07), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.12)))
                    .padding(.top, 70)
                Spacer()
                ZStack {
                    Circle().fill(RadialGradient(colors: [glow.opacity(0.32), glow.opacity(0)],
                                                 center: .center, startRadius: 0, endRadius: 118))
                        .frame(width: 236, height: 236)
                        .scaleEffect(pulse ? 1.14 : 1.0).opacity(pulse ? 0.85 : 0.5)
                        .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: pulse)
                    Circle().stroke(Color.white.opacity(0.12), lineWidth: 5).frame(width: 208, height: 208)
                    Circle().trim(from: 0, to: ringProgress)
                        .stroke(accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 208, height: 208).rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: ringProgress)
                    AloeRosette(length: 88).opacity(leftApp ? 0.55 : 1).saturation(leftApp ? 0.4 : 1)
                        .shadow(color: glow.opacity(0.45), radius: 18)
                }
                .frame(width: 236, height: 236)
                VStack(spacing: 4) {
                    Text(leftApp ? "Session unterbrochen" : "Fokussiert am Lesen")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(leftApp ? accent : Color(hex: 0xF2EBD7))
                    Text(leftApp ? "Diese Session zählt diesmal leider nicht."
                                 : "Leg das Handy weg und genieße dein Buch.")
                        .font(.system(size: 14)).foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 14).animation(.easeInOut, value: leftApp)
                Spacer()
                Label("Verlässt du die App, zählt diese Session nicht.", systemImage: "lock.fill")
                    .font(.system(size: 12)).foregroundStyle(Color(hex: 0xA9BB86).opacity(0.85)).padding(.top, 16)
                Button { showQuitConfirm = true } label: {
                    Label("Fertig", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .foregroundStyle(Color(hex: 0xF2EBD7))
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.2)))
                }
                .padding(.horizontal, 28).padding(.top, 16).padding(.bottom, 40)
            }
        }
        .onReceive(tick) { _ in elapsed = Date().timeIntervalSince(startDate) }
        .onAppear { startDate = Date(); pulse = true; UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .onChange(of: scenePhase) { _, newPhase in if newPhase == .background { leftApp = true } }
        .confirmationDialog("Session beenden?", isPresented: $showQuitConfirm, titleVisibility: .visible) {
            Button(leftApp ? "Beenden (nicht gezählt)" : "Beenden & speichern") {
                onFinish(elapsed, !leftApp); dismiss()
            }
            Button("Weiterlesen", role: .cancel) { }
        } message: {
            Text(leftApp ? "Du hast die App zwischendurch verlassen – der Garten wächst diesmal nicht."
                         : "\(Int(elapsed / 60)) Min werden deinem Garten gutgeschrieben.")
        }
    }
}

// MARK: - Reward

struct RewardView: View {
    var minutesAdded: Int
    var progress: Progress
    var onContinue: () -> Void
    @State private var float = false

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0xF6EAD0), Color(hex: 0xEEE3CE), Color(hex: 0xE7DBC3)],
                           center: UnitPoint(x: 0.5, y: -0.04), startRadius: 0, endRadius: 620)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Text("GESCHAFFT").font(.system(size: 11.5, weight: .bold)).kerning(2.4)
                    .foregroundStyle(Color.clay)
                    .padding(.vertical, 7).padding(.horizontal, 15)
                    .background(Color.sand, in: Capsule()).padding(.top, 70)

                ZStack(alignment: .bottom) { PotView(width: 150); AloeRosette(length: 96).offset(y: -38) }
                    .offset(y: float ? -7 : 0)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: float)
                    .padding(.vertical, 14)

                Text("Deine Aloe\nist \(Text("gewachsen.").italic().foregroundColor(.clay))")
                    .font(.system(size: 31, design: .serif)).multilineTextAlignment(.center).foregroundStyle(Color.ink)

                Text("Eine ruhige Session hat deinem Garten \(Text("\(minutesAdded) Minuten").fontWeight(.semibold).foregroundColor(Color(hex: 0x3C3A2E))) geschenkt.")
                    .font(.system(size: 15)).foregroundStyle(Color(hex: 0x6B6553))
                    .multilineTextAlignment(.center).lineSpacing(3).frame(maxWidth: 290).padding(.top, 10)

                HStack(spacing: 0) {
                    summaryCell("+\(minutesAdded)", "Minuten", accent: true)
                    Divider().frame(height: 36)
                    summaryCell("\(progress.sessionCount)", "Sessions")
                    Divider().frame(height: 36)
                    summaryCell("\(progress.streak)", "Tage Serie")
                }
                .background(Color.surface, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color(hex: 0x36492F, alpha: 0.3), radius: 12, y: 8)
                .padding(.top, 18)

                VStack(spacing: 9) {
                    HStack {
                        Text("Level \(progress.level)").font(.system(size: 13.5, weight: .semibold)).foregroundStyle(Color(hex: 0x3C3A2E))
                        Spacer()
                        Text("noch \(30 - progress.minutesInLevel) Min bis Level \(progress.level + 1)")
                            .font(.system(size: 12)).foregroundStyle(Color(hex: 0x8A8268))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(hex: 0x2B3326, alpha: 0.13))
                            Capsule().fill(LinearGradient(colors: [Color(hex: 0x7E9A5C), Color.clay],
                                                          startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(9, geo.size.width * progress.fraction))
                        }
                    }
                    .frame(height: 9)
                }
                .padding(16).background(Color.surface, in: RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color(hex: 0x36492F, alpha: 0.3), radius: 12, y: 8).padding(.top, 16)

                Spacer()
                Button(action: onContinue) { Text("Weiter zum Garten") }.buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 30).padding(.bottom, 30)
        }
        .onAppear { float = true }
    }
    private func summaryCell(_ value: String, _ label: String, accent: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 23, design: .serif)).foregroundStyle(accent ? Color.clay : Color.ink)
            Text(label).font(.system(size: 11)).foregroundStyle(Color.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
    }
}

// MARK: - Stats

struct StatistikView: View {
    var progress: Progress
    @Environment(\.dismiss) private var dismiss
    @State private var sessions: [SessionRecord] = ReadingData.loadSessions()

    private struct DayBar { let label: String; let minutes: Int; let isToday: Bool }
    private let weekdayLabels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    private var week: [DayBar] {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let today = cal.startOfDay(for: Date())
        let monday = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        return (0..<7).map { offset in
            let day = cal.date(byAdding: .day, value: offset, to: monday)!
            let secs = sessions.filter { cal.isDate($0.date, inSameDayAs: day) }
                               .reduce(0) { $0 + $1.seconds }
            return DayBar(label: weekdayLabels[offset], minutes: Int(secs / 60),
                          isToday: cal.isDate(day, inSameDayAs: today))
        }
    }
    private var weekTotalMinutes: Int { week.reduce(0) { $0 + $1.minutes } }
    private var weekMaxMinutes: Int { max(1, week.map(\.minutes).max() ?? 0) }
    private var recentSessions: [SessionRecord] { Array(sessions.sorted { $0.date > $1.date }.prefix(5)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Überblick").font(.system(size: 13)).foregroundStyle(Color.darkMuted)
                        Text("Statistik").font(.system(size: 28, design: .serif)).foregroundStyle(Color.darkText)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x7E9A5C)).frame(width: 38, height: 38)
                            .background(Color.darkSurface, in: RoundedRectangle(cornerRadius: 12))
                    }
                }

                ZStack(alignment: .bottomTrailing) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gesamt gelesen").font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                        Text(progress.hoursLabel).font(.system(size: 42, design: .serif)).foregroundStyle(Color(hex: 0xF1EAD6))
                        Text("\(progress.sessionCount) Sessions · aktuelle Serie \(progress.streak) Tage")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.7)).padding(.top, 4)
                    }
                    .padding(22).frame(maxWidth: .infinity, alignment: .leading)
                    AloeRosette(length: 90).opacity(0.5).offset(x: 10, y: 20).allowsHitTesting(false)
                }
                .background(LinearGradient(colors: [Color(hex: 0x37492F), Color(hex: 0x2C3B25)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color(hex: 0x000000, alpha: 0.5), radius: 16, y: 12)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Diese Woche").font(.system(size: 18, design: .serif)).foregroundStyle(Color.darkText)
                        Spacer()
                        Text("\(weekTotalMinutes) Min").font(.system(size: 12.5)).foregroundStyle(Color.darkMuted)
                    }
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<week.count, id: \.self) { i in
                            let bar = week[i]
                            VStack(spacing: 7) {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(bar.isToday ? Color.clay : Color(hex: 0xB9C79C))
                                    .frame(maxWidth: 24)
                                    .frame(height: max(4, 88 * CGFloat(bar.minutes) / CGFloat(weekMaxMinutes)))
                                Text(bar.label).font(.system(size: 11, weight: bar.isToday ? .semibold : .regular))
                                    .foregroundStyle(bar.isToday ? Color.darkText : Color.darkMuted)
                            }
                            .frame(maxWidth: .infinity, minHeight: 104)
                        }
                    }
                }
                .padding(18).background(Color.darkSurface, in: RoundedRectangle(cornerRadius: 22))
                .shadow(color: Color(hex: 0x000000, alpha: 0.3), radius: 8, y: 6)

                Text("Gesammelte Pflanzen").font(.system(size: 18, design: .serif)).foregroundStyle(Color.darkText)
                HStack(spacing: 10) {
                    collectionChip { Sprout(scale: 0.6) }
                    collectionChip { AloeRosette(length: 46) }
                    collectionChip { ZStack(alignment: .bottom) { AloeRosette(length: 40); BloomSpike(height: 64) } }
                    RoundedRectangle(cornerRadius: 16).fill(Color.darkSurface.opacity(0.5))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex: 0x5E7350), style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                        .overlay(Text("?").font(.system(size: 24, design: .serif)).foregroundStyle(Color.darkMuted))
                        .aspectRatio(1, contentMode: .fit)
                }

                Text("Letzte Sessions").font(.system(size: 18, design: .serif)).foregroundStyle(Color.darkText).padding(.top, 4)
                if recentSessions.isEmpty {
                    Text("Noch keine Sessions – starte deine erste Lese-Session.")
                        .font(.system(size: 13)).foregroundStyle(Color.darkMuted).padding(.vertical, 8)
                } else {
                    VStack(spacing: 0) {
                        ForEach(recentSessions, id: \.date) { s in
                            sessionRow(sessionTitle(s.date), growthLabel(s.minutes), "\(s.minutes) Min")
                        }
                    }
                }
            }
            .padding(.horizontal, 22).padding(.top, 24).padding(.bottom, 40)
        }
        .background(Color.darkBg.ignoresSafeArea())
    }
    private func sessionTitle(_ date: Date) -> String {
        let cal = Calendar.current
        let time = date.formatted(.dateTime.hour().minute())
        let day: String
        if cal.isDateInToday(date) { day = "Heute" }
        else if cal.isDateInYesterday(date) { day = "Gestern" }
        else { day = date.formatted(.dateTime.weekday(.abbreviated)) }
        return "\(day) · \(time)"
    }
    private func growthLabel(_ minutes: Int) -> String {
        switch minutes {
        case ..<15: return "Spross gepflanzt"
        case ..<30: return "Aloe gewachsen"
        default:    return "Aloe blüht"
        }
    }
    private func collectionChip<V: View>(@ViewBuilder _ content: () -> V) -> some View {
        content().frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit)
            .background(Color.darkSurface, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: 0x000000, alpha: 0.3), radius: 6, y: 4)
    }
    private func sessionRow(_ title: String, _ sub: String, _ duration: String) -> some View {
        HStack(spacing: 13) {
            AloeRosette(length: 30).frame(width: 40, height: 40)
                .background(Color(hex: 0x2A3826), in: RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 14.5, weight: .semibold)).foregroundStyle(Color.darkText)
                Text(sub).font(.system(size: 12.5)).foregroundStyle(Color.darkMuted)
            }
            Spacer()
            Text(duration).font(.system(size: 14.5, weight: .bold)).foregroundStyle(Color.clay)
        }
        .padding(.vertical, 13)
        .overlay(Rectangle().fill(Color(hex: 0xFFFFFF, alpha: 0.08)).frame(height: 1), alignment: .top)
    }
}

#Preview("Launch")     { LaunchView { } }
#Preview("Onboarding") { OnboardingView { } }
#Preview("Garten")     { GartenView() }
#Preview("Fokus")      { FocusSessionView { _, _ in } }
#Preview("Belohnung")  { RewardView(minutesAdded: 24, progress: Progress(totalSeconds: 6480, sessionCount: 14, streak: 6)) { } }
#Preview("Statistik")  { StatistikView(progress: Progress(totalSeconds: 6480, sessionCount: 14, streak: 6)) }
