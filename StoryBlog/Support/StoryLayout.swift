import SwiftUI
import UIKit

enum StoryLayout {
    static let exportSize = CGSize(width: 1080, height: 1920)

    static let horizontalPadding: CGFloat = 96
    static let topPadding: CGFloat = 166
    static let bottomPadding: CGFloat = 146

    static let titleFontSize: CGFloat = 84
    static let bodyFontSize: CGFloat = 42
    static let metadataFontSize: CGFloat = 30

    static let titleLineSpacing: CGFloat = 6
    static let bodyLineSpacing: CGFloat = 12
    static let metadataLineSpacing: CGFloat = 4

    static let titleBodySpacing: CGFloat = 44
    static let bodyMetadataSpacing: CGFloat = 58
    static let headerRuleHeight: CGFloat = 8
    static let headerRuleBottomSpacing: CGFloat = 66

    static let contentWidth = exportSize.width - (horizontalPadding * 2)
    static let maxContentHeight = exportSize.height - topPadding - bottomPadding
    static let fixedHeaderHeight = headerRuleHeight + headerRuleBottomSpacing

    static let titleUIFont = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)
    static let bodyUIFont = UIFont(name: "Georgia", size: bodyFontSize)
        ?? UIFont.systemFont(ofSize: bodyFontSize, weight: .regular)
    static let metadataUIFont = UIFont.systemFont(ofSize: metadataFontSize, weight: .medium)

    static var titleFont: Font {
        .system(size: titleFontSize, weight: .bold, design: .default)
    }

    static var bodyFont: Font {
        .custom(bodyUIFont.fontName, size: bodyFontSize)
    }

    static var metadataFont: Font {
        .system(size: metadataFontSize, weight: .medium, design: .default)
    }
}
