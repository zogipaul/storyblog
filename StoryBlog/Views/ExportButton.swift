import SwiftUI

struct ExportButton: View {
    let isDisabled: Bool
    let isExporting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isExporting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white.opacity(0.95))
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
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule(style: .continuous)
                    .fill(.black.opacity(isDisabled || isExporting ? 0.42 : 0.88))
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            }
            .shadow(color: .black.opacity(isDisabled || isExporting ? 0 : 0.16), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .disabled(isDisabled || isExporting)
    }
}
