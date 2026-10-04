import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let device: AVCaptureDevice?
    let zoom: CGFloat
    let rotation: Int
    let brightness: Double
    let contrast: Double

    func makeUIView(context: Context) -> PreviewView {
        PreviewView()
    }

    func updateUIView(_ view: PreviewView, context: Context) {
        view.configure(device: device)
        view.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(rotation) * .pi / 180))
        view.layer.setValue(zoom, forKeyPath: "transform.scale")
        view.alpha = CGFloat(max(0.25, min(1, 1 + brightness * 0.45)))
        // Contrast is implemented in PreviewView using Core Image in the next hardware-validation pass.
        view.contrast = contrast
    }
}

final class PreviewView: UIView {
    private var session: AVCaptureSession?
    private var currentID: String?
    var contrast: Double = 1

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    func configure(device: AVCaptureDevice?) {
        guard let device, currentID != device.uniqueID else { return }
        currentID = device.uniqueID
        session?.stopRunning()
        let s = AVCaptureSession()
        s.sessionPreset = .high
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if s.canAddInput(input) { s.addInput(input) }
            previewLayer.session = s
            previewLayer.videoGravity = .resizeAspect
            session = s
            DispatchQueue.global(qos: .userInitiated).async { s.startRunning() }
        } catch {
            currentID = nil
        }
    }
}
