import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false

    private let benefits: [(icon: String, text: String)] = [
        ("text.bubble.fill", "Journal of your reflections on each day's practice"),
        ("flame.fill", "Streak of days you completed the micro-action"),
        ("books.vertical.fill", "Browse the full library of past principles")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        benefitsSection
                        purchaseSection
                        footerSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Practice Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: store.isPro) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.qmAccent)
                .padding(.top, 12)

            Text("Practice Pro")
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)

            Text("$0.99 / month. Auto-renews until you cancel.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                HStack(spacing: 16) {
                    Image(systemName: benefit.icon)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.qmAccent)
                        .frame(width: 24)

                    Text(benefit.text)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.vertical, 14)

                if index < benefits.count - 1 {
                    Divider()
                        .padding(.leading, 40)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Purchase

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            Button {
                isPurchasing = true
                Haptics.tap()
                Task {
                    await store.purchase()
                    isPurchasing = false
                }
            } label: {
                HStack(spacing: 8) {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    }
                    Text(isPurchasing ? "Unlocking..." : "Unlock for \(store.displayPrice)/month")
                        .frame(maxWidth: .infinity)
                }
            }
            .prominentButton()
            .disabled(isPurchasing)

            Button {
                Task { await store.restore() }
            } label: {
                Text("Restore Purchase")
            }
            .softButton()
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 10) {
            Text("Subscription automatically renews at \(store.displayPrice)/month unless cancelled at least 24 hours before the end of the current period. Cancel anytime in Settings > Subscriptions.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.caption)
                    .foregroundStyle(Color.qmAccent)

                Text("·")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/practice-site/privacy.html")!)
                    .font(.caption)
                    .foregroundStyle(Color.qmAccent)
            }
        }
    }
}
