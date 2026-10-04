import AVFoundation
import SwiftUI

@MainActor
final class DualCameraManager: ObservableObject {
    @Published var devices: [AVCaptureDevice] = []
    @Published var errorMessage: String?
    let left = CameraPaneModel()
    let right = CameraPaneModel()

    init() {
        refresh()
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func refresh() {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.external],
                                                       mediaType: .video,
                                                       position: .unspecified)
        devices = session.devices
        if left.device == nil { left.device = devices.first }
        if right.device == nil { right.device = devices.dropFirst().first }
    }

    func setFocus(_ model: CameraPaneModel, auto: Bool) {
        guard let d = model.device else { return }
        do {
            try d.lockForConfiguration()
            defer { d.unlockForConfiguration() }
            if auto {
                if d.isFocusModeSupported(.continuousAutoFocus) {
                    d.focusMode = .continuousAutoFocus
                } else if d.isFocusModeSupported(.autoFocus) {
                    d.focusMode = .autoFocus
                } else {
                    errorMessage = "\(d.localizedName): Autofokus wird von iPadOS nicht angeboten."
                }
            } else if d.isFocusModeSupported(.locked) {
                d.setFocusModeLocked(lensPosition: model.manualFocus)
            } else {
                errorMessage = "\(d.localizedName): Manueller Fokus wird von iPadOS nicht angeboten."
            }
        } catch { errorMessage = error.localizedDescription }
    }
}
