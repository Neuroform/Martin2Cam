import SwiftUI
import AVFoundation
import CoreImage
import MetalKit

struct CameraPreview: UIViewRepresentable {
    let device: AVCaptureDevice?
    let zoom: CGFloat
    let rotation: Int
    let brightness: Double
    let contrast: Double

    func makeUIView(context: Context) -> FilteredPreviewView { FilteredPreviewView() }

    func updateUIView(_ view: FilteredPreviewView, context: Context) {
        view.configure(device: device)
        view.zoom = zoom
        view.rotationDegrees = rotation
        view.brightness = brightness
        view.contrast = contrast
    }
}

final class FilteredPreviewView: MTKView, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureQueue = DispatchQueue(label: "Martin2Cam.capture")
    private let renderQueue = DispatchQueue(label: "Martin2Cam.render")
    private let ciContext: CIContext
    private var session: AVCaptureSession?
    private var currentID: String?

    var zoom: CGFloat = 1
    var rotationDegrees = 0
    var brightness = 0.0
    var contrast = 1.0

    override init(frame: CGRect, device: MTLDevice?) {
        let metal = MTLCreateSystemDefaultDevice()!
        ciContext = CIContext(mtlDevice: metal)
        super.init(frame: frame, device: metal)
        framebufferOnly = false
        enableSetNeedsDisplay = false
        isPaused = true
        autoResizeDrawable = true
        backgroundColor = .black
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(device: AVCaptureDevice?) {
        guard let device else {
            currentID = nil
            session?.stopRunning()
            session = nil
            return
        }
        guard currentID != device.uniqueID else { return }
        currentID = device.uniqueID
        session?.stopRunning()

        let s = AVCaptureSession()
        s.beginConfiguration()
        s.sessionPreset = .high
        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard s.canAddInput(input) else { s.commitConfiguration(); return }
            s.addInput(input)
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: captureQueue)
            guard s.canAddOutput(output) else { s.commitConfiguration(); return }
            s.addOutput(output)
            s.commitConfiguration()
            session = s
            captureQueue.async { s.startRunning() }
        } catch {
            s.commitConfiguration()
            currentID = nil
        }
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var image = CIImage(cvPixelBuffer: buffer)
        let extent = image.extent

        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)
        filter.setValue(1.0, forKey: kCIInputSaturationKey)
        if let out = filter.outputImage { image = out }

        let radians = CGFloat(rotationDegrees) * .pi / 180
        let center = CGPoint(x: extent.midX, y: extent.midY)
        var transform = CGAffineTransform(translationX: center.x, y: center.y)
        transform = transform.rotated(by: radians)
        transform = transform.scaledBy(x: zoom, y: zoom)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        image = image.transformed(by: transform)

        renderQueue.async { [weak self] in
            guard let self, let drawable = self.currentDrawable else { return }
            let target = CGRect(origin: .zero, size: self.drawableSize)
            let sx = target.width / image.extent.width
            let sy = target.height / image.extent.height
            let scale = min(sx, sy)
            let fitted = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let x = (target.width - fitted.extent.width) / 2 - fitted.extent.minX
            let y = (target.height - fitted.extent.height) / 2 - fitted.extent.minY
            let centered = fitted.transformed(by: CGAffineTransform(translationX: x, y: y))
            self.ciContext.render(centered, to: drawable.texture,
                                  commandBuffer: nil,
                                  bounds: target,
                                  colorSpace: CGColorSpaceCreateDeviceRGB())
            drawable.present()
        }
    }
}
