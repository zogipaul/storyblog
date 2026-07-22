import SwiftUI

struct EditorView: View {
    @AppStorage("appAppearance") private var appAppearanceRaw = AppAppearance.system.rawValue
    @AppStorage("storyHistory") private var storyHistoryData = Data()
    @Environment(\.colorScheme) private var colorScheme

    @State private var draft = StoryDraft()
    @State private var isExporting = false
    @State private var isShowingHistory = false
    @State private var alert: ExportAlert?

    private var contentHeight: CGFloat {
        TextMeasurement.contentHeight(for: draft)
    }

    private var isTooLong: Bool {
        contentHeight > StoryLayout.maxContentHeight
    }

    private var appAppearance: AppAppearance {
        get {
            AppAppearance(rawValue: appAppearanceRaw) ?? .system
        }
        nonmutating set {
            appAppearanceRaw = newValue.rawValue
        }
    }

    private var appAppearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { appAppearance },
            set: { appAppearance = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    previewSection
                    editorFields
                    validationSection
                    ExportButton(
                        isDisabled: isTooLong,
                        isExporting: isExporting,
                        action: exportStory
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("StoryBlog")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        isShowingHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 15, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Story history")

                    Button(action: startNewStory) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                    }
                    .disabled(isDraftEmpty)
                    .accessibilityLabel("New story")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    appearanceMenu
                }
            }
            .sheet(isPresented: $isShowingHistory) {
                StoryHistoryView(
                    stories: storyHistory,
                    onSelect: loadStory,
                    onDelete: deleteStories
                )
            }
            .alert(item: $alert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var appearanceMenu: some View {
        Menu {
            Picker("Appearance", selection: appAppearanceBinding) {
                ForEach(AppAppearance.allCases) { appearance in
                    Label(appearance.title, systemImage: appearance.systemImage)
                        .tag(appearance)
                }
            }
        } label: {
            Image(systemName: appAppearance.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
        }
        .accessibilityLabel("Appearance")
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Story Preview")
                .font(.headline)

            GeometryReader { geometry in
                StoryPreviewView(draft: draft)
                    .frame(width: geometry.size.width, height: geometry.size.width * 16 / 9)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(previewBorderColor, lineWidth: 1)
                    }
                    .shadow(color: previewShadowColor, radius: 18, x: 0, y: 10)
            }
            .aspectRatio(9 / 16, contentMode: .fit)
        }
    }

    private var editorFields: some View {
        VStack(alignment: .leading, spacing: 14) {
            StoryInputField(title: "Title", systemImage: "textformat.size") {
                TextField("A sharp, story-sized headline", text: $draft.title, axis: .vertical)
                    .font(.body.weight(.medium))
                    .lineLimit(1...3)
                    .textInputAutocapitalization(.sentences)
                    .multilineTextAlignment(.leading)
                    .storyInputPadding()
            }

            StoryInputField(title: "Body", systemImage: "text.alignleft") {
                TextEditor(text: $draft.body)
                    .font(.body)
                    .lineSpacing(3)
                    .frame(minHeight: 184)
                    .scrollContentBackground(.hidden)
                    .storyInputPadding()
            }

            StoryInputField(title: "Author/date", systemImage: "calendar") {
                TextField("Optional", text: $draft.authorDateLine, axis: .vertical)
                    .font(.body.weight(.medium))
                    .lineLimit(1...2)
                    .textInputAutocapitalization(.words)
                    .multilineTextAlignment(.leading)
                    .storyInputPadding()
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: fieldCardShadowColor, radius: 18, x: 0, y: 10)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(fieldCardBorderColor, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var validationSection: some View {
        if isTooLong {
            Label("Text is too long for one Story", systemImage: "exclamationmark.triangle.fill")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            HStack {
                Label("Fits one Story", systemImage: "checkmark.circle.fill")
                Spacer()
                Text("\(Int(contentHeight)) / \(Int(StoryLayout.maxContentHeight)) px")
                    .monospacedDigit()
            }
            .font(.callout.weight(.medium))
            .foregroundStyle(.green)
        }
    }

    private var previewBorderColor: Color {
        colorScheme == .dark ? .white.opacity(0.14) : .black.opacity(0.08)
    }

    private var previewShadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.36) : .black.opacity(0.12)
    }

    private var fieldCardBorderColor: Color {
        colorScheme == .dark ? .white.opacity(0.08) : .white.opacity(0.72)
    }

    private var fieldCardShadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.28) : .black.opacity(0.06)
    }

    private var storyHistory: [StoryHistoryItem] {
        decodeStoryHistory()
    }

    private func exportStory() {
        guard !isTooLong, !isExporting else { return }

        isExporting = true

        Task {
            do {
                try await ExportService.exportStoryImage(for: draft, colorScheme: colorScheme)
                let wasSavedToHistory = saveCurrentStoryToHistory()
                alert = ExportAlert(
                    title: "Export Complete",
                    message: wasSavedToHistory
                        ? "Your 1080 x 1920 PNG was saved to Photos and added to history."
                        : "Your 1080 x 1920 PNG was saved to Photos."
                )
            } catch {
                alert = ExportAlert(
                    title: "Export Failed",
                    message: error.localizedDescription
                )
            }

            isExporting = false
        }
    }

    private func loadStory(_ story: StoryHistoryItem) {
        draft = story.draft
        isShowingHistory = false
    }

    private func startNewStory() {
        draft = StoryDraft()
    }

    private func saveCurrentStoryToHistory() -> Bool {
        guard !isDraftEmpty else { return false }

        var stories = decodeStoryHistory()
        stories.removeAll { $0.draft == draft }
        stories.insert(StoryHistoryItem(draft: draft), at: 0)
        saveStoryHistory(Array(stories.prefix(30)))

        return true
    }

    private func deleteStories(at offsets: IndexSet) {
        var stories = decodeStoryHistory()
        stories.remove(atOffsets: offsets)
        saveStoryHistory(stories)
    }

    private var isDraftEmpty: Bool {
        draft.trimmedTitle.isEmpty &&
            draft.trimmedBody.isEmpty &&
            draft.trimmedAuthorDateLine.isEmpty
    }

    private func decodeStoryHistory() -> [StoryHistoryItem] {
        guard !storyHistoryData.isEmpty else { return [] }

        return (try? JSONDecoder().decode([StoryHistoryItem].self, from: storyHistoryData)) ?? []
    }

    private func saveStoryHistory(_ stories: [StoryHistoryItem]) {
        storyHistoryData = (try? JSONEncoder().encode(stories)) ?? Data()
    }
}

private struct ExportAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct StoryInputField<Content: View>: View {
    let title: String
    let systemImage: String
    private let content: Content
    @Environment(\.colorScheme) private var colorScheme

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Label {
                Text(title)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 15)
            }
            .labelStyle(.titleAndIcon)

            content
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color(uiColor: .systemBackground).opacity(0.86))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(inputBorderColor, lineWidth: 1)
                }
        }
    }

    private var inputBorderColor: Color {
        colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.07)
    }
}

private struct StoryHistoryView: View {
    let stories: [StoryHistoryItem]
    let onSelect: (StoryHistoryItem) -> Void
    let onDelete: (IndexSet) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if stories.isEmpty {
                    ContentUnavailableView(
                        "No Past Stories",
                        systemImage: "clock",
                        description: Text("Export a story to keep it here.")
                    )
                } else {
                    List {
                        ForEach(stories) { story in
                            Button {
                                onSelect(story)
                            } label: {
                                StoryHistoryRow(story: story)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: onDelete)
                    }
                }
            }
            .navigationTitle("Past Stories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct StoryHistoryRow: View {
    let story: StoryHistoryItem

    private var title: String {
        let trimmedTitle = story.draft.trimmedTitle
        return trimmedTitle.isEmpty ? "Untitled Story" : trimmedTitle
    }

    private var bodyPreview: String {
        let trimmedBody = story.draft.trimmedBody
        return trimmedBody.isEmpty ? "No body text" : trimmedBody
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer(minLength: 8)

                Text(story.createdAt, style: .date)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(bodyPreview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if !story.draft.trimmedAuthorDateLine.isEmpty {
                Text(story.draft.trimmedAuthorDateLine)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
    }
}

private extension View {
    func storyInputPadding() -> some View {
        padding(.horizontal, 14)
            .padding(.vertical, 12)
    }
}
