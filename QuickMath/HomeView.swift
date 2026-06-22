import SwiftUI

struct HomeView: View {
    var forceScreen: String? = nil

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store

    @State private var showSettings = false
    @State private var showInsights = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        metricsRow
                        GridView()
                            .environmentObject(appModel)
                            .environmentObject(store)
                        proSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color.qmAccent)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(appModel)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showInsights) {
                InsightsView()
                    .environmentObject(appModel)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(store)
            }
            .onAppear {
                if forceScreen == "insights" { showInsights = true }
                if forceScreen == "paywall" { showPaywall = true }
                if forceScreen == "settings" { showSettings = true }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(todayDateString)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Today's Principle")
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date())
    }

    // MARK: - Metrics row

    private var metricsRow: some View {
        HStack(spacing: 12) {
            MetricTile(
                value: "\(appModel.streak)",
                label: appModel.streak == 1 ? "Day Streak" : "Day Streak"
            )
            MetricTile(
                value: "\(appModel.allLessons.filter(\.didPractice).count)",
                label: "Completed"
            )
            MetricTile(
                value: "\(appModel.allLessons.count)",
                label: "Unlocked"
            )
        }
    }

    // MARK: - Pro section

    private var proSection: some View {
        Button {
            if store.isPro {
                showInsights = true
            } else {
                showPaywall = true
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: store.isPro ? "chart.bar.fill" : "lock.fill")
                    .font(.title3)
                    .foregroundStyle(Color.qmAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.qmAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(store.isPro ? "Your Insights" : "Practice Pro")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(store.isPro ? "Streaks, journal & full library" : "Unlock streaks, journal & library")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
