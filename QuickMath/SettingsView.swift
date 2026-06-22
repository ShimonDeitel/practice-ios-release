import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @AppStorage("quickmath.theme") private var themeRaw = AppTheme.system.rawValue

    @State private var showDeleteConfirm = false
    @State private var showPaywall = false

    private var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                List {
                    proSection
                    appearanceSection
                    linksSection
                    dangerSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.qmAccent)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(store)
            }
            .confirmationDialog(
                "Delete all data?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete All Data", role: .destructive) {
                    appModel.deleteAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently erase all your lessons, reflections, and logs.")
            }
        }
    }

    // MARK: - Pro

    private var proSection: some View {
        Section("Subscription") {
            if store.isPro {
                HStack {
                    Label("Practice Pro", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(Color.qmAccent)
                    Spacer()
                    Text("Active")
                        .font(.subheadline)
                        .foregroundStyle(Color.qmCorrect)
                }

                Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                    Label("Manage Subscription", systemImage: "arrow.up.right")
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    Label("Unlock Practice Pro", systemImage: "leaf.fill")
                        .foregroundStyle(Color.qmAccent)
                }

                Button {
                    Task { await store.restore() }
                } label: {
                    Label("Restore Purchase", systemImage: "arrow.clockwise")
                }
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $themeRaw) {
                ForEach(AppTheme.allCases) { themeOption in
                    Text(themeOption.label).tag(themeOption.rawValue)
                }
            }
        }
    }

    // MARK: - Links

    private var linksSection: some View {
        Section("Legal") {
            Link(destination: URL(string: "https://shimondeitel.github.io/practice-site/privacy.html")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
        }
    }

    // MARK: - Danger

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
            }
        }
    }
}
