import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var manager: DualCameraManager

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 1) {
                pane(manager.left).frame(width: geo.size.width / 2)
                pane(manager.right).frame(width: geo.size.width / 2)
            }
            .background(.black)
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func pane(_ model: CameraPaneModel) -> some View {
        ZStack(alignment: .bottom) {
            CameraPreview(device: model.device, zoom: model.zoom, rotation: model.rotation,
                          brightness: model.brightness, contrast: model.contrast)
                .background(.black)
                .clipped()
                .onTapGesture { model.showControls.toggle() }

            if model.device == nil {
                VStack {
                    Text("USB-Kamera nicht ausgewählt")
                    Button("Neu suchen") { manager.refresh() }
                }
            }

            if model.showControls {
                controls(model)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .padding()
            }
        }
    }

    private func controls(_ model: CameraPaneModel) -> some View {
        VStack(spacing: 8) {
            Picker("Kamera", selection: Binding(
                get: { model.device?.uniqueID ?? "" },
                set: { id in model.device = manager.devices.first { $0.uniqueID == id } }
            )) {
                Text("Keine").tag("")
                ForEach(manager.devices, id: \.uniqueID) { Text($0.localizedName).tag($0.uniqueID) }
            }
            HStack {
                Text("Zoom")
                Slider(value: $model.zoom, in: 1...4)
                Button("↻") { model.rotation = (model.rotation + 90) % 360 }
            }
            HStack { Text("Helligkeit"); Slider(value: $model.brightness, in: -1...1) }
            HStack { Text("Kontrast"); Slider(value: $model.contrast, in: 0.5...2) }
            HStack {
                Button("AF") { manager.setFocus(model, auto: true) }
                Button("MF") { manager.setFocus(model, auto: false) }
                Slider(value: $model.manualFocus, in: 0...1)
                    .onChange(of: model.manualFocus) { _, _ in manager.setFocus(model, auto: false) }
            }
        }
        .font(.caption)
    }
}
