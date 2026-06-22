import SwiftUI

struct GridView: View {
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var store: Store

    @State private var reflectionText = ""
    @State private var showReflectionField = false
    @State private var didJustComplete = false

    var body: some View {
        VStack(spacing: 20) {
            if let lesson = appModel.todayLesson {
                principleCard(lesson: lesson)
                microActionCard(lesson: lesson)

                if !lesson.didPractice {
                    practiceButton(lesson: lesson)
                } else {
                    completedBadge(lesson: lesson)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(40)
            }
        }
    }

    // MARK: - Principle card

    private func principleCard(lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.qmAccent)
                Spacer()
            }
            Text(lesson.principle)
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Text("— \(lesson.source)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .qmCard()
    }

    // MARK: - Micro action card

    private func microActionCard(lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.qmAccent)
                Text("Today's Practice")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.qmAccent)
            }
            Text(lesson.microAction)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .qmCard()
    }

    // MARK: - Practice button

    private func practiceButton(lesson: Lesson) -> some View {
        VStack(spacing: 16) {
            if showReflectionField {
                VStack(alignment: .leading, spacing: 10) {
                    Text("How did it go? (optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ZStack(alignment: .topLeading) {
                        if reflectionText.isEmpty {
                            Text("Share a reflection...")
                                .foregroundStyle(.tertiary)
                                .font(.body)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $reflectionText)
                            .font(.body)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                    }
                }
                .qmCard()
            }

            HStack(spacing: 12) {
                if !showReflectionField {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showReflectionField = true
                        }
                        Haptics.tap()
                    } label: {
                        Text("Add Reflection")
                    }
                    .softButton()
                }

                Button {
                    appModel.markPracticed(lesson: lesson, note: reflectionText)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        didJustComplete = true
                    }
                } label: {
                    Text("Mark as Done")
                        .frame(maxWidth: .infinity)
                }
                .prominentButton()
            }
        }
    }

    // MARK: - Completed badge

    private func completedBadge(lesson: Lesson) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.qmCorrect)
                Text("Practiced today")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.qmCorrect)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.qmCorrect.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            if !lesson.reflection.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your reflection")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(lesson.reflection)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .qmCard()
            }
        }
    }
}
