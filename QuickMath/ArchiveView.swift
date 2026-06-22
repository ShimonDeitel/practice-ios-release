import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                QMBackground()
                VStack(spacing: 0) {
                    Picker("Section", selection: $selectedTab) {
                        Text("Journal").tag(0)
                        Text("Library").tag(1)
                        Text("Streak").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    Divider()

                    switch selectedTab {
                    case 0:
                        journalList
                    case 1:
                        libraryList
                    default:
                        streakView
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.qmAccent)
                }
            }
        }
    }

    // MARK: - Journal (reflections)

    private var journalList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let reflected = appModel.allLessons.filter { !$0.reflection.isEmpty }
                if reflected.isEmpty {
                    emptyState(
                        icon: "text.bubble",
                        title: "No reflections yet",
                        subtitle: "Write a reflection when you complete today's practice to see it here."
                    )
                } else {
                    ForEach(reflected, id: \.id) { lesson in
                        journalCard(lesson: lesson)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    private func journalCard(lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(lesson.dateUnlocked, style: .date)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.qmAccent)
                Spacer()
                if lesson.didPractice {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.qmCorrect)
                }
            }
            Text(lesson.principle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
            if !lesson.reflection.isEmpty {
                Text(lesson.reflection)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .qmCard()
    }

    // MARK: - Library (all lessons)

    private var libraryList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appModel.allLessons, id: \.id) { lesson in
                    libraryCard(lesson: lesson)
                }
                if appModel.allLessons.isEmpty {
                    emptyState(
                        icon: "books.vertical",
                        title: "No past principles",
                        subtitle: "Principles you've unlocked will appear here."
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    private func libraryCard(lesson: Lesson) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack {
                Image(systemName: lesson.didPractice ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(lesson.didPractice ? Color.qmCorrect : Color(uiColor: .tertiaryLabel))
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.principle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("— \(lesson.source)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                Text(lesson.dateUnlocked, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Streak

    private var streakView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main streak
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.qmAccent)
                    Text("\(appModel.streak)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(appModel.streak == 1 ? "Day Streak" : "Day Streak")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                // Summary stats
                HStack(spacing: 12) {
                    MetricTile(
                        value: "\(appModel.allLessons.filter(\.didPractice).count)",
                        label: "Total Completed"
                    )
                    MetricTile(
                        value: "\(appModel.allLessons.count)",
                        label: "Days Unlocked"
                    )
                    MetricTile(
                        value: completionRate,
                        label: "Completion Rate"
                    )
                }

                // Recent 7-day grid
                recent7DayGrid
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    private var completionRate: String {
        let total = appModel.allLessons.count
        guard total > 0 else { return "0%" }
        let done = appModel.allLessons.filter(\.didPractice).count
        let pct = Int((Double(done) / Double(total)) * 100)
        return "\(pct)%"
    }

    private var recent7DayGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(0..<7) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date())!
                    let dayStart = Calendar.current.startOfDay(for: date)
                    let lesson = appModel.allLessons.first(where: {
                        Calendar.current.isDate($0.dateUnlocked, inSameDayAs: dayStart)
                    })
                    let done = lesson?.didPractice ?? false
                    let hasLesson = lesson != nil

                    VStack(spacing: 6) {
                        Text(dayLetter(date))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                        Circle()
                            .fill(done ? Color.qmAccent : (hasLesson ? Color.qmHair : Color.clear))
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle().strokeBorder(done ? Color.clear : Color.qmHair, lineWidth: 1.5)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.qmCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func dayLetter(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return String(f.string(from: date).prefix(1))
    }

    // MARK: - Empty state

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.qmAccent.opacity(0.6))
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
