import Foundation

struct StoryDraft: Codable, Equatable {
    var title: String = ""
    var body: String = ""
    var authorDateLine: String = ""

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedAuthorDateLine: String {
        authorDateLine.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct StoryHistoryItem: Codable, Identifiable, Equatable {
    let id: UUID
    var draft: StoryDraft
    var createdAt: Date

    init(id: UUID = UUID(), draft: StoryDraft, createdAt: Date = .now) {
        self.id = id
        self.draft = draft
        self.createdAt = createdAt
    }
}
