import Photos
import SwiftUI
import UIKit

enum ExportError: LocalizedError {
    case photoLibraryDenied
    case renderFailed
    case pngEncodingFailed

    var errorDescription: String? {
        switch self {
        case .photoLibraryDenied:
            return "Photo Library access was not granted."
        case .renderFailed:
            return "The story image could not be rendered."
        case .pngEncodingFailed:
            return "The story image could not be encoded as PNG."
        }
    }
}

@MainActor
enum ExportService {
    static func exportStoryImage(for draft: StoryDraft) async throws {
        let image = try renderStoryImage(for: draft)
        let pngData = try pngData(from: image)

        try await requestPhotoAddPermission()
        try await savePNGToPhotoLibrary(pngData)
    }

    private static func renderStoryImage(for draft: StoryDraft) throws -> UIImage {
        let exportView = StoryPreviewView(draft: draft)
            .frame(width: StoryLayout.exportSize.width, height: StoryLayout.exportSize.height)

        let renderer = ImageRenderer(content: exportView)
        renderer.proposedSize = ProposedViewSize(StoryLayout.exportSize)
        renderer.scale = 1

        guard let image = renderer.uiImage else {
            throw ExportError.renderFailed
        }

        return image
    }

    private static func pngData(from image: UIImage) throws -> Data {
        guard let data = image.pngData() else {
            throw ExportError.pngEncodingFailed
        }

        return data
    }

    private static func requestPhotoAddPermission() async throws {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch currentStatus {
        case .authorized, .limited:
            return
        case .notDetermined:
            let newStatus = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    continuation.resume(returning: status)
                }
            }

            guard newStatus == .authorized || newStatus == .limited else {
                throw ExportError.photoLibraryDenied
            }
        case .denied, .restricted:
            throw ExportError.photoLibraryDenied
        @unknown default:
            throw ExportError.photoLibraryDenied
        }
    }

    private static func savePNGToPhotoLibrary(_ pngData: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                request.addResource(with: .photo, data: pngData, options: options)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: ExportError.renderFailed)
                }
            }
        }
    }
}
