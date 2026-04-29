import SwiftUI

struct StoryPreviewView: View {
    let draft: StoryDraft

    var body: some View {
        GeometryReader { geometry in
            let scale = min(
                geometry.size.width / StoryLayout.exportSize.width,
                geometry.size.height / StoryLayout.exportSize.height
            )

            StoryCanvasContent(draft: draft)
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

    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.953, blue: 0.925)

            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 2)
                .padding(44)

            VStack(alignment: .leading, spacing: 0) {
                Capsule()
                    .fill(Color.black.opacity(0.86))
                    .frame(width: 88, height: StoryLayout.headerRuleHeight)
                    .padding(.bottom, StoryLayout.headerRuleBottomSpacing)

                if !draft.trimmedTitle.isEmpty {
                    Text(draft.trimmedTitle)
                        .font(StoryLayout.titleFont)
                        .lineSpacing(StoryLayout.titleLineSpacing)
                        .foregroundStyle(Color(red: 0.08, green: 0.075, blue: 0.065))
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
                        .foregroundStyle(Color(red: 0.14, green: 0.13, blue: 0.11))
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !draft.trimmedAuthorDateLine.isEmpty {
                    if !draft.trimmedTitle.isEmpty || !draft.trimmedBody.isEmpty {
                        Spacer()
                            .frame(height: StoryLayout.bodyMetadataSpacing)
                    }

                    Text(draft.trimmedAuthorDateLine.uppercased())
                        .font(StoryLayout.metadataFont)
                        .tracking(1.8)
                        .lineSpacing(StoryLayout.metadataLineSpacing)
                        .foregroundStyle(Color.black.opacity(0.58))
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
}
