import SwiftUI

struct StoryPreviewView: View {
    let draft: StoryDraft
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / StoryLayout.exportSize.width,
                geometry.size.height / StoryLayout.exportSize.height
            )

            StoryCanvasContent(draft: draft)
                .environment(\.colorScheme, colorScheme)
                .frame(width: StoryLayout.exportSize.width, height: StoryLayout.exportSize.height)
                .scaleEffect(scale, anchor: .topLeading)
                .frame(
                    width: StoryLayout.exportSize.width * scale,
                    height: StoryLayout.exportSize.height * scale,
                    alignment: .topLeading
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(9 / 16, contentMode: .fit)
    }
}

private struct StoryCanvasContent: View {
    let draft: StoryDraft
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            canvasBackgroundColor

            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(canvasBorderColor, lineWidth: 2)
                .padding(44)

            VStack(alignment: .leading, spacing: 0) {
                Capsule()
                    .fill(ruleColor)
                    .frame(width: 88, height: StoryLayout.headerRuleHeight)
                    .padding(.bottom, StoryLayout.headerRuleBottomSpacing)

                if !draft.trimmedTitle.isEmpty {
                    Text(draft.trimmedTitle)
                        .font(StoryLayout.titleFont)
                        .lineSpacing(StoryLayout.titleLineSpacing)
                        .foregroundStyle(titleColor)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !draft.trimmedTitle.isEmpty, !draft.trimmedBody.isEmpty {
                    Spacer()
                        .frame(height: StoryLayout.titleBodySpacing)
                }

                if !draft.trimmedBody.isEmpty {
                    Text(draft.trimmedBody)
                        .font(StoryLayout.bodyFont)
                        .lineSpacing(StoryLayout.bodyLineSpacing)
                        .foregroundStyle(bodyColor)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !draft.trimmedAuthorDateLine.isEmpty {
                    if !draft.trimmedTitle.isEmpty || !draft.trimmedBody.isEmpty {
                        Spacer()
                            .frame(height: StoryLayout.bodyMetadataSpacing)
                    }

                    Text(draft.trimmedAuthorDateLine.uppercased())
                        .font(StoryLayout.metadataFont)
                        .tracking(StoryLayout.metadataTracking)
                        .lineSpacing(StoryLayout.metadataLineSpacing)
                        .foregroundStyle(metadataColor)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, StoryLayout.horizontalPadding)
            .padding(.top, StoryLayout.topPadding)
            .padding(.bottom, StoryLayout.bottomPadding)
        }
        .clipped()
    }

    private var canvasBackgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 0.075, green: 0.079, blue: 0.088)
            : Color(red: 0.965, green: 0.953, blue: 0.925)
    }

    private var canvasBorderColor: Color {
        colorScheme == .dark ? .white.opacity(0.12) : .black.opacity(0.08)
    }

    private var ruleColor: Color {
        colorScheme == .dark ? .white.opacity(0.88) : .black.opacity(0.86)
    }

    private var titleColor: Color {
        colorScheme == .dark
            ? Color(red: 0.94, green: 0.93, blue: 0.89)
            : Color(red: 0.08, green: 0.075, blue: 0.065)
    }

    private var bodyColor: Color {
        colorScheme == .dark
            ? Color(red: 0.83, green: 0.84, blue: 0.81)
            : Color(red: 0.14, green: 0.13, blue: 0.11)
    }

    private var metadataColor: Color {
        colorScheme == .dark ? .white.opacity(0.58) : .black.opacity(0.58)
    }
}
