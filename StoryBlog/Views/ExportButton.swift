import SwiftUI

struct ExportButton: View {
    let isDisabled: Bool
    let isExporting: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isExporting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(buttonForegroundColor.opacity(0.95))
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 15, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 17, height: 17)
                }

                Text(isExporting ? "Exporting..." : "Export PNG")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(buttonForegroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule(style: .continuous)
                    .fill(buttonFill)
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(buttonBorderColor, lineWidth: 1)
            }
            .shadow(color: buttonShadowColor, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .disabled(isDisabled || isExporting)
    }

    private var buttonFill: Color {
        if colorScheme == .dark {
            if isDisabled {
                return .white.opacity(0.18)
            }

            return .white.opacity(isExporting ? 0.72 : 0.92)
        }

        if isDisabled {
            return .black.opacity(0.24)
        }

        return .black.opacity(isExporting ? 0.68 : 0.88)
    }

    private var buttonForegroundColor: Color {
        if colorScheme == .dark {
            return isDisabled ? .white.opacity(0.54) : .black.opacity(0.92)
        }

        return isDisabled ? .white.opacity(0.76) : .white
    }

    private var buttonBorderColor: Color {
        colorScheme == .dark ? .black.opacity(0.22) : .white.opacity(0.22)
    }

    private var buttonShadowColor: Color {
        guard !isDisabled, !isExporting else { return .black.opacity(0) }
        return colorScheme == .dark ? .black.opacity(0.34) : .black.opacity(0.16)
    }
}
