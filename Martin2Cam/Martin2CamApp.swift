import SwiftUI

@main
struct Martin2CamApp: App {
    @StateObject private var cameras = DualCameraManager()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(cameras)
        }
    }
}
