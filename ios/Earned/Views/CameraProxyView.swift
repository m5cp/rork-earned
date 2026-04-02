import SwiftUI
import AVFoundation

struct CameraProxyView: View {
    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void

    var body: some View {
        Group {
            #if targetEnvironment(simulator)
            CameraUnavailablePlaceholder(onCancel: onCancel)
            #else
            if AVCaptureDevice.default(for: .video) != nil {
                ImagePickerCamera(onCapture: onCapture, onCancel: onCancel)
            } else {
                CameraUnavailablePlaceholder(onCancel: onCancel)
            }
            #endif
        }
    }
}

struct CameraUnavailablePlaceholder: View {
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("Camera Preview")
                    .font(.title2.weight(.semibold))

                Text("Install this app on your device\nvia the Rork App to use the camera.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Go Back") {
                    onCancel()
                }
                .font(.body.weight(.medium))
                .padding(.top, 8)
            }
        }
    }
}

struct ImagePickerCamera: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, onCancel: onCancel)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let onCancel: () -> Void

        init(onCapture: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onCancel = onCancel
        }

        nonisolated func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            Task { @MainActor in
                if let image {
                    onCapture(image)
                } else {
                    onCancel()
                }
            }
        }

        nonisolated func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            Task { @MainActor in
                onCancel()
            }
        }
    }
}
