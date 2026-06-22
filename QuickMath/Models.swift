import SwiftUI
import SwiftData

// MARK: - SwiftData models

@Model
final class Lesson {
    var id: UUID
    var principle: String
    var source: String
    var microAction: String
    var dateUnlocked: Date
    var didPractice: Bool
    var reflection: String

    init(
        id: UUID = UUID(),
        principle: String,
        source: String,
        microAction: String,
        dateUnlocked: Date = Date(),
        didPractice: Bool = false,
        reflection: String = ""
    ) {
        self.id = id
        self.principle = principle
        self.source = source
        self.microAction = microAction
        self.dateUnlocked = dateUnlocked
        self.didPractice = didPractice
        self.reflection = reflection
    }
}

@Model
final class PracticeLog {
    var lessonID: UUID
    var completedAt: Date
    var note: String

    init(lessonID: UUID, completedAt: Date = Date(), note: String = "") {
        self.lessonID = lessonID
        self.completedAt = completedAt
        self.note = note
    }
}

// MARK: - Wisdom library (built-in daily content)

private let wisdomLibrary: [(principle: String, source: String, microAction: String)] = [
    ("The obstacle is the way.", "Marcus Aurelius", "Name one obstacle in your day and write down one way it can make you stronger."),
    ("You have power over your mind, not outside events.", "Marcus Aurelius", "When something frustrates you today, pause and ask: 'What's within my control here?'"),
    ("Waste no more time arguing what a good person should be. Be one.", "Marcus Aurelius", "Do one small kind act today without telling anyone."),
    ("It is not the man who has too little, but the man who craves more, that is poor.", "Seneca", "Before any purchase today, ask yourself if you truly need it."),
    ("Dwell on the beauty of life. Watch the stars, and see yourself running with them.", "Marcus Aurelius", "Spend 2 minutes outside noticing something beautiful you usually ignore."),
    ("He suffers more than necessary who suffers before it is necessary.", "Seneca", "Notice one worry today and ask: 'Is this actually happening right now?'"),
    ("No man was ever wise by chance.", "Seneca", "Read or listen to something genuinely educational for at least 10 minutes."),
    ("Luck is what happens when preparation meets opportunity.", "Seneca", "Identify one skill and spend 15 minutes deliberately practicing it."),
    ("Begin at once to live, and count each separate day as a separate life.", "Seneca", "Write down the single most important thing you want to accomplish today."),
    ("Accept the things to which fate binds you.", "Marcus Aurelius", "Accept one thing you cannot change and consciously release the tension about it."),
    ("The first and greatest victory is to conquer yourself.", "Plato", "Resist one small temptation today — food, phone, impulse — and notice how it feels."),
    ("Knowing yourself is the beginning of all wisdom.", "Aristotle", "Write three honest adjectives that describe you at your best and your worst."),
    ("We are what we repeatedly do. Excellence, then, is not an act, but a habit.", "Aristotle", "Do one small thing that aligns with who you want to become."),
    ("Educating the mind without educating the heart is no education at all.", "Aristotle", "Do one act of genuine compassion today with no expectation of return."),
    ("Count him braver who overcomes his desires than him who conquers his enemies.", "Aristotle", "Identify one desire you'll intentionally delay gratifying today."),
    ("The unexamined life is not worth living.", "Socrates", "Take 5 minutes tonight to reflect: What went well? What could improve?"),
    ("True knowledge exists in knowing that you know nothing.", "Socrates", "In one conversation today, ask a question and listen without preparing your reply."),
    ("Every day is a fresh start.", "Lao Tzu", "Let go of one grudge or regret from yesterday and start this day anew."),
    ("A journey of a thousand miles begins with a single step.", "Lao Tzu", "Take the very first step toward something you've been postponing."),
    ("Nature does not hurry, yet everything is accomplished.", "Lao Tzu", "Do one task today with complete focus and no rushing."),
    ("The man who moves a mountain begins by carrying away small stones.", "Confucius", "Break down your biggest current goal into three smaller actions."),
    ("When you know a thing, hold that you know it; when you do not know a thing, allow that you do not know it.", "Confucius", "Say 'I don't know' honestly at least once today instead of guessing."),
    ("Our greatest glory is not in never falling, but in rising every time we fall.", "Confucius", "Recall one recent failure and write one lesson it taught you."),
    ("Happiness is not something ready made. It comes from your own actions.", "Dalai Lama", "Do one proactive act that creates joy — for yourself or someone else."),
    ("If you want others to be happy, practice compassion.", "Dalai Lama", "Notice someone struggling today and offer practical help, not just sympathy."),
    ("The secret of getting ahead is getting started.", "Mark Twain", "Start something you've been putting off — even for just five minutes."),
    ("Be yourself; everyone else is already taken.", "Oscar Wilde", "Do one thing today that is authentically you, even if others might not approve."),
    ("In the middle of difficulty lies opportunity.", "Albert Einstein", "Identify one current difficulty and brainstorm one hidden opportunity inside it."),
    ("A person who never made a mistake never tried anything new.", "Albert Einstein", "Attempt something small where failure is possible — stretch yourself."),
    ("Simplicity is the ultimate sophistication.", "Leonardo da Vinci", "Simplify one thing in your environment — a process, a space, a commitment."),
    ("The only way to do great work is to love what you do.", "Steve Jobs", "Spend 10 minutes doing something you genuinely love and notice your energy."),
    ("Don't watch the clock; do what it does. Keep going.", "Sam Levenson", "When you feel like stopping on a task, commit to five more minutes."),
    ("Everything you've ever wanted is on the other side of fear.", "George Addair", "Name one fear that's holding you back and take one tiny step toward it."),
    ("The best time to plant a tree was 20 years ago. The second best time is now.", "Chinese Proverb", "Start something today you wish you'd started earlier."),
    ("Fall seven times, stand up eight.", "Japanese Proverb", "Think of something you gave up on and decide whether it deserves one more try."),
    ("This too shall pass.", "Persian Proverb", "When feeling low today, remind yourself: this state is temporary."),
    ("Still water runs deep.", "Latin Proverb", "Spend 5 minutes in complete silence — no phone, no distraction."),
    ("An ounce of prevention is worth a pound of cure.", "Benjamin Franklin", "Identify one problem brewing that you can prevent now with small effort."),
    ("Either write something worth reading or do something worth writing.", "Benjamin Franklin", "Accomplish something today you'd be proud to tell someone about."),
    ("Well done is better than well said.", "Benjamin Franklin", "Replace one thing you've been talking about doing with actually doing it."),
    ("Without continual growth and progress, words like improvement and success have no meaning.", "Benjamin Franklin", "Track one metric of growth today — steps, pages read, kind acts."),
    ("Do what you can, with what you have, where you are.", "Theodore Roosevelt", "Stop waiting for perfect conditions and take one meaningful action right now."),
    ("Nothing in life is to be feared, only to be understood.", "Marie Curie", "Research something that intimidates you — learn three facts about it."),
    ("Change your thoughts and you change your world.", "Norman Vincent Peale", "Replace one negative thought today with a realistic, constructive alternative."),
    ("Act as if what you do makes a difference. It does.", "William James", "Choose one small action today and do it as though it deeply matters."),
    ("The most common form of despair is not being who you are.", "Soren Kierkegaard", "Do one thing today that expresses who you genuinely are."),
    ("He who has a why to live can bear almost any how.", "Friedrich Nietzsche", "Write down your personal 'why' — the deeper reason behind your daily effort."),
    ("What we think, we become.", "Buddha", "Observe your most repeated thought today. Does it serve you?"),
    ("Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.", "Buddha", "Set your phone aside for 10 minutes and fully engage with what's in front of you."),
    ("Peace comes from within. Do not seek it without.", "Buddha", "Take three slow, deep breaths whenever you feel unsettled today."),
    ("The mind is everything. What you think you become.", "Buddha", "Choose one belief that limits you and consciously challenge it today."),
    ("One today is worth two tomorrows.", "Benjamin Franklin", "Pick one task you've been deferring and complete it today."),
    ("The whole secret of a successful life is to find out what is one's destiny to do, and then do it.", "Henry Ford", "Spend 5 minutes writing about what work feels like a calling to you."),
    ("Life is 10% what happens to us and 90% how we react to it.", "Charles R. Swindoll", "Notice one event that frustrates you and consciously choose your response."),
    ("In three words I can sum up everything I've learned about life: it goes on.", "Robert Frost", "Think of your most stressful current problem. In 5 years, will it matter?"),
    ("You miss 100% of the shots you don't take.", "Wayne Gretzky", "Send that message, make that call, or make that ask you've been avoiding."),
    ("Whether you think you can or you think you can't, you're right.", "Henry Ford", "Before a challenging task, say out loud: 'I can do this.'"),
    ("Believe you can and you're halfway there.", "Theodore Roosevelt", "Identify one goal you doubt yourself on and list three reasons you're capable."),
    ("Spread love everywhere you go.", "Mother Teresa", "Compliment three people genuinely and specifically today."),
    ("If you judge people, you have no time to love them.", "Mother Teresa", "Notice one time you judge someone today and try understanding them instead."),
    ("Success is not final, failure is not fatal: it is the courage to continue that counts.", "Winston Churchill", "Keep going on one project or habit you've nearly given up on."),
    ("The price of greatness is responsibility.", "Winston Churchill", "Take full ownership of one outcome in your life — no blame, no excuses."),
    ("The pessimist sees difficulty in every opportunity. The optimist sees opportunity in every difficulty.", "Winston Churchill", "Reframe one current difficulty as an opportunity in writing.")
]

// MARK: - AppModel

@MainActor
final class AppModel: ObservableObject {
    let container: ModelContainer
    weak var store: Store?

    @Published private(set) var todayLesson: Lesson?
    @Published private(set) var allLessons: [Lesson] = []
    @Published private(set) var logs: [PracticeLog] = []
    @Published private(set) var streak: Int = 0

    init(container: ModelContainer) {
        self.container = container
        reload()
    }

    static func makeContainer() -> ModelContainer {
        let schema = Schema([Lesson.self, PracticeLog.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return (try? ModelContainer(for: schema, configurations: [fallback]))!
        }
    }

    func reload() {
        let context = container.mainContext
        let lessonDescriptor = FetchDescriptor<Lesson>(sortBy: [SortDescriptor(\.dateUnlocked, order: .reverse)])
        let logDescriptor = FetchDescriptor<PracticeLog>(sortBy: [SortDescriptor(\.completedAt, order: .reverse)])

        allLessons = (try? context.fetch(lessonDescriptor)) ?? []
        logs = (try? context.fetch(logDescriptor)) ?? []

        ensureTodayLesson()
        computeStreak()
    }

    func refresh() {
        reload()
    }

    // MARK: - Today's lesson

    private func ensureTodayLesson() {
        let context = container.mainContext
        let today = Calendar.current.startOfDay(for: Date())

        // Find if we already have a lesson for today
        if let existing = allLessons.first(where: {
            Calendar.current.isDate($0.dateUnlocked, inSameDayAs: today)
        }) {
            todayLesson = existing
            return
        }

        // Determine next wisdom entry
        let usedCount = allLessons.count
        let entry = wisdomLibrary[usedCount % wisdomLibrary.count]

        let lesson = Lesson(
            principle: entry.principle,
            source: entry.source,
            microAction: entry.microAction,
            dateUnlocked: Date()
        )
        context.insert(lesson)
        try? context.save()

        allLessons.insert(lesson, at: 0)
        todayLesson = lesson
    }

    // MARK: - Mark practiced

    func markPracticed(lesson: Lesson, note: String = "") {
        let context = container.mainContext
        lesson.didPractice = true
        lesson.reflection = note

        let log = PracticeLog(lessonID: lesson.id, note: note)
        context.insert(log)
        try? context.save()

        reload()
        Haptics.success()
    }

    // MARK: - Streak computation

    private func computeStreak() {
        var current = 0
        var checkDate = Calendar.current.startOfDay(for: Date())

        while true {
            let hasLesson = allLessons.first(where: {
                Calendar.current.isDate($0.dateUnlocked, inSameDayAs: checkDate) && $0.didPractice
            }) != nil

            if hasLesson {
                current += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        streak = current
    }

    // MARK: - Delete all data

    func deleteAllData() {
        let context = container.mainContext
        for lesson in allLessons { context.delete(lesson) }
        for log in logs { context.delete(log) }
        try? context.save()
        allLessons = []
        logs = []
        todayLesson = nil
        streak = 0
        reload()
    }
}
