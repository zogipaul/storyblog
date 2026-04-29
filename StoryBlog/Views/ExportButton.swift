import SwiftUI

struct ExportButton: View {
    let isDisabled: Bool
    let isExporting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(isExporting ? "Exporting..." : "Export Story Image")
                    .frame(maxWidth: .infinity)
            } icon: {
                if isExporting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .font(.headline)
            .padding(.vertical, 15)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isDisabled || isExporting)
    }
}
