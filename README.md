# Martin2Cam

Dual-UVC viewer for iPad: two external USB document cameras in a true 50:50 landscape view.

Target: IPEVO V4K Ultra + JOURIST DC990.

Controls per pane: camera selection, digital zoom, 90° rotation, brightness, contrast, autofocus and manual focus where iPadOS exposes those controls for the UVC device.

## Build
The project uses XcodeGen. Install XcodeGen, run `xcodegen generate`, then open `Martin2Cam.xcodeproj` in Xcode and select your signing team.

## Validation
Compile/simulator validation is not hardware validation. Dual-UVC and focus controls must be verified on the target iPad with both physical cameras connected simultaneously.
