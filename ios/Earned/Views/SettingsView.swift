import SwiftUI
import UserNotifications

struct SettingsView: View {
    let viewModel: EarnedViewModel
    var store: StoreViewModel
    @State private var showResetAlert: Bool = false
    @State private var showSubscription: Bool = false
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
    @State private var appeared: Bool = false
    @State private var levelBounce: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    profileHeader
                        .padding(.bottom, 20)

                    milestonesPreview
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    subscriptionCard
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    VStack(spacing: 16) {
                        settingsGroup(title: "Reminders", icon: "bell.fill", iconColor: EarnedColors.accent) {
                            dailyNudgeContent
                            Divider().padding(.leading, 16)
                            weeklyMomentumContent
                        }

                        settingsGroup(title: "Integrations", icon: "link", iconColor: EarnedColors.momentum) {
                            calendarSyncContent
                        }

                        settingsGroup(title: "Appearance", icon: "paintbrush.fill", iconColor: EarnedColors.streak) {
                            appearanceContent
                        }

                        settingsGroup(title: "Privacy", icon: "lock.shield.fill", iconColor: EarnedColors.earned) {
                            privacyContent
                        }

                        settingsGroup(title: "Support", icon: "lifepreserver.fill", iconColor: EarnedColors.accent) {
                            supportContent
                        }

                        settingsGroup(title: "Legal", icon: "doc.text.fill", iconColor: .secondary) {
                            legalContent
                        }

                        settingsGroup(title: "Data", icon: "cylinder.split.1x2.fill", iconColor: EarnedColors.strength) {
                            dataContent
                        }

                        aboutCard
                    }
                    .padding(.horizontal)

                    footerText
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadNudgeState()
                weeklyMomentumEnabled = UserDefaults.standard.bool(forKey: "weeklyMomentumEnabled")
                calendarSyncEnabled = CalendarSyncService.shared.isSyncEnabled
                if reduceMotion { appeared = true }
                else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
                Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    levelBounce += 1
                }
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
            .sheet(isPresented: $showSubscription) {
                SubscriptionView(store: store)
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
            .sheet(isPresented: $showEULA) {
                EULAView()
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 0) {
            ZStack {
                EarnedColors.immersiveGradient

                RadialGradient(
                    colors: [EarnedColors.momentum.opacity(0.25), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 250
                )

                RadialGradient(
                    colors: [EarnedColors.accent.opacity(0.15), Color.clear],
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 200
                )

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 80, height: 80)

                        Circle()
                            .strokeBorder(
                                AngularGradient(
                                    colors: [EarnedColors.accent, EarnedColors.momentum, EarnedColors.earned, EarnedColors.accent],
                                    center: .center
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 80, height: 80)

                        Text("\(viewModel.currentLevel)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .raisedHeadline()
                            .symbolEffect(.bounce, value: levelBounce)
                    }
                    .scaleEffect(appeared ? 1 : 0.7)
                    .opacity(appeared ? 1 : 0)
                    .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.6), value: appeared)

                    VStack(spacing: 6) {
                        Text(viewModel.levelTitle.uppercased())
                            .font(.caption.weight(.heavy))
                            .tracking(2)
                            .foregroundStyle(EarnedColors.accentBright)

                        if viewModel.currentLevel < 10 {
                            HStack(spacing: 8) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(.white.opacity(0.15))
                                            .frame(height: 6)

                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [EarnedColors.accent, EarnedColors.momentum],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: max(6, geo.size.width * viewModel.levelProgress), height: 6)
                                            .animation(reduceMotion ? nil : .spring(response: 0.8), value: viewModel.levelProgress)
                                    }
                                }
                                .frame(height: 6)
                                .frame(maxWidth: 160)

                                Text("Lv \(viewModel.currentLevel + 1)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)

                    HStack(spacing: 0) {
                        headerStat(value: "\(viewModel.currentStreak)", label: "Streak", icon: "flame.fill")
                        headerStatDivider
                        headerStat(value: "\(viewModel.totalDaysCheckedIn)", label: "Days", icon: "checkmark.circle.fill")
                        headerStatDivider
                        headerStat(value: "\(viewModel.totalWinsEarned)", label: "Wins", icon: "star.fill")
                    }
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 14))
                    .padding(.horizontal, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.15), value: appeared)
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func headerStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()

            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.5)
            }
            .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private var headerStatDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 0.5, height: 30)
    }

    // MARK: - Milestones Preview

    private var milestonesPreview: some View {
        NavigationLink {
            MilestonesView(viewModel: viewModel)
        } label: {
            VStack(spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(EarnedColors.streak)
                        Text("Milestones")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("\(viewModel.unlockedMilestones.count)/\(MilestoneLibrary.all.count)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }

                if !viewModel.unlockedMilestones.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.unlockedMilestones.suffix(6).reversed()) { milestone in
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [milestone.color.opacity(0.25), milestone.color.opacity(0.08)],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 20
                                            )
                                        )
                                        .frame(width: 42, height: 42)

                                    Image(systemName: milestone.icon)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(milestone.color)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .contentMargins(.horizontal, 0)
                }

                if let next = viewModel.nextMilestones.first {
                    HStack(spacing: 10) {
                        let current: Int = switch next.type {
                        case .streak: viewModel.longestStreak
                        case .totalWins: viewModel.totalWinsEarned
                        case .totalDays: viewModel.totalDaysCheckedIn
                        case .comeback: viewModel.totalComebacks
                        case .category: 0
                        }
                        let progress = min(1.0, Double(current) / Double(next.requirement))

                        Image(systemName: next.icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(next.color.opacity(0.6))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next: \(next.title)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(height: 5)

                                    Capsule()
                                        .fill(next.color.opacity(0.6))
                                        .frame(width: max(5, geo.size.width * progress), height: 5)
                                }
                            }
                            .frame(height: 5)
                        }

                        Text("\(current)/\(next.requirement)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.tertiary)
                            .monospacedDigit()
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    // MARK: - Subscription Card

    private var subscriptionCard: some View {
        Group {
            if store.isPremium {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(EarnedColors.streak.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(EarnedColors.streak)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Earned Pro")
                            .font(.subheadline.weight(.bold))
                        Text("Full access unlocked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundStyle(EarnedColors.earned)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 18))
            } else {
                Button {
                    showSubscription = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [EarnedColors.accent.opacity(0.3), EarnedColors.momentum.opacity(0.15)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 22
                                    )
                                )
                                .frame(width: 44, height: 44)

                            Image(systemName: "trophy.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(EarnedColors.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Pro")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.primary)
                            Text("Unlock the full experience")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    // MARK: - Settings Group

    private func settingsGroup<Content: View>(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(iconColor)
                Text(title.uppercased())
                    .font(.caption.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                content()
            }
            .padding(.vertical, 4)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    // MARK: - Daily Nudge

    private var dailyNudgeContent: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $nudgeEnabled) {
                settingsRow(icon: "bell.badge.fill", iconColor: EarnedColors.accent, title: "Daily Nudge", subtitle: "A calm, optional reminder")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .onChange(of: nudgeEnabled) { _, newValue in
                if newValue { requestAndScheduleNudge() }
                else { cancelNudge() }
            }

            if nudgeEnabled {
                Divider().padding(.leading, 56)

                DatePicker("Time", selection: $nudgeTime, displayedComponents: .hourAndMinute)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .padding(.leading, 40)
                    .onChange(of: nudgeTime) { _, _ in rescheduleNudge() }

                Divider().padding(.leading, 56)

                Picker("Frequency", selection: $nudgeFrequency) {
                    ForEach(DailyNudgeService.NudgeFrequency.allCases) { freq in
                        Text(freq.displayName).tag(freq)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .padding(.leading, 40)
                .onChange(of: nudgeFrequency) { _, _ in rescheduleNudge() }
            }
        }
    }

    // MARK: - Weekly Momentum

    private var weeklyMomentumContent: some View {
        Toggle(isOn: $weeklyMomentumEnabled) {
            settingsRow(icon: "chart.line.uptrend.xyaxis", iconColor: EarnedColors.momentum, title: "Weekly Momentum", subtitle: "Positive weekly summary")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .onChange(of: weeklyMomentumEnabled) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "weeklyMomentumEnabled")
            if newValue { requestWeeklyMomentum() }
            else { WeeklyMomentumService.cancelWeeklyNotification() }
        }
    }

    // MARK: - Calendar Sync

    private var calendarSyncContent: some View {
        Toggle(isOn: $calendarSyncEnabled) {
            settingsRow(icon: "calendar.badge.plus", iconColor: EarnedColors.momentum, title: "Sync to Calendar", subtitle: "Add sessions to Apple Calendar")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .onChange(of: calendarSyncEnabled) { _, newValue in
            if newValue { enableCalendarSync() }
            else { CalendarSyncService.shared.isSyncEnabled = false }
        }
    }

    // MARK: - Appearance

    private var appearanceContent: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(EarnedColors.streak.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(EarnedColors.streak)
            }

            Picker("Theme", selection: $appTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Privacy

    private var privacyContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(EarnedColors.earned.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(EarnedColors.earned)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Data Stays on Device")
                        .font(.subheadline.weight(.medium))
                    Text("Nothing uploaded or shared")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().padding(.leading, 62)

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(EarnedColors.accent.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(EarnedColors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("No Tracking")
                        .font(.subheadline.weight(.medium))
                    Text("No analytics, no third-party SDKs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Support

    private var supportContent: some View {
        VStack(spacing: 0) {
            NavigationLink {
                SupportView()
            } label: {
                settingsNavRow(icon: "lifepreserver.fill", iconColor: EarnedColors.accent, title: "Help & Support")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().padding(.leading, 62)

            NavigationLink {
                AccessibilityInfoView()
            } label: {
                settingsNavRow(icon: "accessibility", iconColor: EarnedColors.accent, title: "Accessibility")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Legal

    private var legalContent: some View {
        VStack(spacing: 0) {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                settingsNavRow(icon: "lock.shield", iconColor: .secondary, title: "Privacy Policy")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().padding(.leading, 62)

            NavigationLink {
                TermsOfUseView()
            } label: {
                settingsNavRow(icon: "doc.text", iconColor: .secondary, title: "Terms of Use")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().padding(.leading, 62)

            Button {
                showEULA = true
            } label: {
                settingsNavRow(icon: "doc.plaintext", iconColor: .secondary, title: "Apple EULA")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().padding(.leading, 62)

            NavigationLink {
                DisclaimerSafetyView()
            } label: {
                settingsNavRow(icon: "exclamationmark.shield", iconColor: .secondary, title: "Disclaimer & Safety")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Data

    private var dataContent: some View {
        Button(role: .destructive) {
            showResetAlert = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemRed).opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red)
                }

                Text("Reset All Data")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - About

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                Text("ABOUT")
                    .font(.caption.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                aboutRow(label: "Version", value: "1.0")
                Divider().padding(.leading, 16)
                aboutRow(label: "Level", value: "\(viewModel.currentLevel) — \(viewModel.levelTitle)")
                Divider().padding(.leading, 16)
                aboutRow(label: "Days Checked In", value: "\(viewModel.totalDaysCheckedIn)")
                Divider().padding(.leading, 16)
                aboutRow(label: "Total Wins", value: "\(viewModel.totalWinsEarned)")
                Divider().padding(.leading, 16)
                aboutRow(label: "Longest Streak", value: "\(viewModel.longestStreak)")
                Divider().padding(.leading, 16)
                aboutRow(label: "Milestones", value: "\(viewModel.unlockedMilestones.count) unlocked")
            }
            .padding(.vertical, 4)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Footer

    private var footerText: some View {
        Text("This app is a personal tracking tool and not a substitute for medical or mental health care.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }

    // MARK: - Row Helpers

    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func settingsNavRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Actions

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
