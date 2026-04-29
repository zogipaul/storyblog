import SwiftUI

struct EditorView: View {
    @State private var draft = StoryDraft()
    @State private var isExporting = false
    @State private var alert: ExportAlert?

    private var contentHeight: CGFloat {
        TextMeasurement.contentHeight(for: draft)
    }

    private var isTooLong: Bool {
        contentHeight > StoryLayout.maxContentHeight
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
            .alert(item: $alert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
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
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
            }
            .aspectRatio(9 / 16, contentMode: .fit)
        }
    }

    private var editorFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            LabeledContent("Title") {
                TextField("A sharp, story-sized headline", text: $draft.title, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Body")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextEditor(text: $draft.body)
                    .frame(minHeight: 190)
                    .padding(8)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    }
            }

            LabeledContent("Author/date") {
                TextField("Optional", text: $draft.authorDateLine, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
            }
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

    private func exportStory() {
        guard !isTooLong, !isExporting else { return }

        isExporting = true

        Task {
            do {
                try await ExportService.exportStoryImage(for: draft)
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
