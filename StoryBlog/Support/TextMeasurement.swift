import UIKit

enum TextMeasurement {
    static func contentHeight(for draft: StoryDraft) -> CGFloat {
        var height: CGFloat = StoryLayout.fixedHeaderHeight
        var hasPreviousBlock = false

        addBlock(
            text: draft.trimmedTitle,
            font: StoryLayout.titleUIFont,
            lineSpacing: StoryLayout.titleLineSpacing,
            spacingBefore: 0,
            height: &height,
            hasPreviousBlock: &hasPreviousBlock
        )

        addBlock(
            text: draft.trimmedBody,
            font: StoryLayout.bodyUIFont,
            lineSpacing: StoryLayout.bodyLineSpacing,
            spacingBefore: StoryLayout.titleBodySpacing,
            height: &height,
            hasPreviousBlock: &hasPreviousBlock
        )

        addBlock(
            text: draft.trimmedAuthorDateLine,
            font: StoryLayout.metadataUIFont,
            lineSpacing: StoryLayout.metadataLineSpacing,
            spacingBefore: StoryLayout.bodyMetadataSpacing,
            height: &height,
            hasPreviousBlock: &hasPreviousBlock
        )

        return ceil(height)
    }

    static func fitsInOneStory(_ draft: StoryDraft) -> Bool {
        contentHeight(for: draft) <= StoryLayout.maxContentHeight
    }

    private static func addBlock(
        text: String,
        font: UIFont,
        lineSpacing: CGFloat,
        spacingBefore: CGFloat,
        height: inout CGFloat,
        hasPreviousBlock: inout Bool
    ) {
        guard !text.isEmpty else { return }

        if hasPreviousBlock {
            height += spacingBefore
        }

        height += measuredHeight(
            text: text,
            font: font,
            lineSpacing: lineSpacing,
            width: StoryLayout.contentWidth
        )
        hasPreviousBlock = true
    }

    private static func measuredHeight(
        text: String,
        font: UIFont,
        lineSpacing: CGFloat,
        width: CGFloat
    ) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = lineSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = text.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        return ceil(rect.height)
    }
}
