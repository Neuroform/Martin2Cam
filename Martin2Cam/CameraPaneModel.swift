import Foundation
import AVFoundation

@MainActor
final class CameraPaneModel: ObservableObject, Identifiable {
    let id = UUID()
    @Published var device: AVCaptureDevice?
    @Published var zoom: CGFloat = 1
    @Published var rotation: Int = 0
    @Published var brightness: Double = 0
    @Published var contrast: Double = 1
    @Published var showControls = false
    @Published var manualFocus: Float = 0.5

    var name: String { device?.localizedName ?? "Keine Kamera" }
}
