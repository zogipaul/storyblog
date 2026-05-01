import SwiftUI

struct EditorView: View {
    @AppStorage("appAppearance") private var appAppearanceRaw = AppAppearance.system.rawValue
    @Environment(\.colorScheme) private var colorScheme

    @State private var draft = StoryDraft()
    @State private var isExporting = false
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
                ToolbarItem(placement: .topBarTrailing) {
                    appearanceMenu
                }
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

    private func exportStory() {
        guard !isTooLong, !isExporting else { return }

        isExporting = true

        Task {
            do {
                try await ExportService.exportStoryImage(for: draft, colorScheme: colorScheme)
                alert = ExportAlert(
                    title: "Export Complete",
                    message: "Your 1080 x 1920 PNG was saved to Photos."
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

private extension View {
    func storyInputPadding() -> some View {
        padding(.horizontal, 14)
            .padding(.vertical, 12)
    }
}
