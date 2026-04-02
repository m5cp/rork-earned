import SwiftUI
import UserNotifications

struct SettingsView: View {
    let viewModel: EarnedViewModel
    @State private var showResetAlert: Bool = false
    @State private var nudgeEnabled: Bool = false
    @State private var nudgeTime: Date = {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }()
    @State private var nudgeFrequency: DailyNudgeService.NudgeFrequency = .daily
    @State private var notificationDenied: Bool = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var showEULA: Bool = false
    @State private var weeklyMomentumEnabled: Bool = false
    @State private var calendarSyncEnabled: Bool = false
    @State private var calendarAccessDenied: Bool = false

    var body: some View {
        NavigationStack {
            List {
                dailyNudgeSection
                weeklyMomentumSection
                calendarSyncSection
                appearanceSection
                privacySection
                supportSection
                legalSection
                disclaimerSection
                dataSection
                aboutSection
                settingsFooter
            }
            .navigationTitle("Settings")
            .onAppear {
                loadNudgeState()
                weeklyMomentumEnabled = UserDefaults.standard.bool(forKey: "weeklyMomentumEnabled")
                calendarSyncEnabled = CalendarSyncService.shared.isSyncEnabled
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "earned_entries")
                    viewModel.entries.removeAll()
                    viewModel.checkInComplete = false
                    viewModel.prepareTodayWins()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your check-in history and streaks.")
            }
            .alert("Calendar Access Denied", isPresented: $calendarAccessDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    calendarSyncEnabled = false
                }
            } message: {
                Text("Enable calendar access in Settings to sync your earned sessions.")
            }
            .alert("Notifications Disabled", isPresented: $notificationDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    nudgeEnabled = false
                }
            } message: {
                Text("Enable notifications in Settings to receive nudges.")
            }
        }
    }

    private var calendarSyncSection: some View {
        Section {
            Toggle("Sync to Calendar", isOn: $calendarSyncEnabled)
                .onChange(of: calendarSyncEnabled) { _, newValue in
                    if newValue {
                        enableCalendarSync()
                    } else {
                        CalendarSyncService.shared.isSyncEnabled = false
                    }
                }
        } header: {
            Text("Apple Calendar")
        } footer: {
            Text("Creates an \"Earned\" calendar with a daily event for each completed session — visible alongside your real schedule.")
        }
    }

    private func enableCalendarSync() {
        Task {
            let granted = await CalendarSyncService.shared.requestAccess()
            if granted {
                CalendarSyncService.shared.isSyncEnabled = true
                viewModel.syncToCalendarIfNeeded()
            } else {
                calendarAccessDenied = true
                calendarSyncEnabled = false
                CalendarSyncService.shared.isSyncEnabled = false
            }
        }
    }

    private var weeklyMomentumSection: some View {
        Section {
            Toggle("Weekly Momentum", isOn: $weeklyMomentumEnabled)
                .onChange(of: weeklyMomentumEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "weeklyMomentumEnabled")
                    if newValue {
                        requestWeeklyMomentum()
                    } else {
                        WeeklyMomentumService.cancelWeeklyNotification()
                    }
                }
        } header: {
            Text("Weekly Summary")
        } footer: {
            Text("Receive a positive weekly summary based on your real activity. Never guilt, only recognition.")
        }
    }

    private func requestWeeklyMomentum() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            Task { @MainActor in
                if granted {
                    viewModel.refreshWeeklyNotification()
                } else {
                    notificationDenied = true
                    weeklyMomentumEnabled = false
                    UserDefaults.standard.set(false, forKey: "weeklyMomentumEnabled")
                }
            }
        }
    }

    private var dailyNudgeSection: some View {
        Section {
            Toggle("Daily Nudge", isOn: $nudgeEnabled)
                .onChange(of: nudgeEnabled) { _, newValue in
                    if newValue {
                        requestAndScheduleNudge()
                    } else {
                        cancelNudge()
                    }
                }

            if nudgeEnabled {
                DatePicker("Time", selection: $nudgeTime, displayedComponents: .hourAndMinute)
                    .onChange(of: nudgeTime) { _, _ in
                        rescheduleNudge()
                    }

                Picker("Frequency", selection: $nudgeFrequency) {
                    ForEach(DailyNudgeService.NudgeFrequency.allCases) { freq in
                        Text(freq.displayName).tag(freq)
                    }
                }
                .onChange(of: nudgeFrequency) { _, _ in
                    rescheduleNudge()
                }
            }
        } header: {
            Text("Daily Nudge")
        } footer: {
            Text("A calm, optional reminder. No pressure, no guilt.")
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $appTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var privacySection: some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: "lock.shield.fill")
                    .font(.body)
                    .foregroundStyle(.green)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Data Stays on Device")
                        .font(.subheadline.weight(.medium))
                    Text("Nothing is uploaded or shared.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(EarnedColors.earned.opacity(0.7))
                }
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)

            HStack(spacing: 14) {
                Image(systemName: "eye.slash.fill")
                    .font(.body)
                    .foregroundStyle(.blue)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("No Tracking")
                        .font(.subheadline.weight(.medium))
                    Text("No analytics, no third-party SDKs.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(EarnedColors.accent.opacity(0.7))
                }
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
        } header: {
            Text("Privacy")
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label("Reset All Data", systemImage: "trash")
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            NavigationLink {
                SupportView()
            } label: {
                Label("Help & Support", systemImage: "lifepreserver.fill")
            }

            NavigationLink {
                AccessibilityInfoView()
            } label: {
                Label("Accessibility", systemImage: "accessibility")
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label("Privacy Policy", systemImage: "lock.shield")
            }
            NavigationLink {
                TermsOfUseView()
            } label: {
                Label("Terms of Use", systemImage: "doc.text")
            }
            Button {
                showEULA = true
            } label: {
                Label("Apple EULA", systemImage: "doc.plaintext")
            }
        }
        .sheet(isPresented: $showEULA) {
            EULAView()
        }
    }

    private var disclaimerSection: some View {
        Section {
            NavigationLink {
                DisclaimerSafetyView()
            } label: {
                Label("Disclaimer & Safety", systemImage: "exclamationmark.shield")
            }
        }
    }

    private var settingsFooter: some View {
        Section {
            Text("This app is a personal tracking tool and not a substitute for medical or mental health care.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .listRowBackground(Color.clear)
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "1.0")
            LabeledContent("Days Checked In", value: "\(viewModel.totalDaysCheckedIn)")
            LabeledContent("Total Wins Earned", value: "\(viewModel.totalWinsEarned)")
        } header: {
            Text("About")
        }
    }

    private func loadNudgeState() {
        nudgeEnabled = UserDefaults.standard.bool(forKey: "nudgeEnabled")
        if let saved = UserDefaults.standard.object(forKey: "nudgeTime") as? Date {
            nudgeTime = saved
        }
        if let rawFreq = UserDefaults.standard.string(forKey: "nudgeFrequency"),
           let freq = DailyNudgeService.NudgeFrequency(rawValue: rawFreq) {
            nudgeFrequency = freq
        }
    }

    private func requestAndScheduleNudge() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            Task { @MainActor in
                if granted {
                    rescheduleNudge()
                } else {
                    notificationDenied = true
                    nudgeEnabled = false
                }
            }
        }
    }

    private func rescheduleNudge() {
        UserDefaults.standard.set(true, forKey: "nudgeEnabled")
        UserDefaults.standard.set(nudgeTime, forKey: "nudgeTime")
        UserDefaults.standard.set(nudgeFrequency.rawValue, forKey: "nudgeFrequency")

        let hasCompleted = viewModel.hasCheckedInToday
        DailyNudgeService.scheduleNudges(
            time: nudgeTime,
            frequency: nudgeFrequency,
            hasCompletedToday: hasCompleted
        )
    }

    private func cancelNudge() {
        UserDefaults.standard.set(false, forKey: "nudgeEnabled")
        DailyNudgeService.cancelAllNudges()
    }
}

nonisolated enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
