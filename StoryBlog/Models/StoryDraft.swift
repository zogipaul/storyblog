import Foundation

struct StoryDraft: Equatable {
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
