# Martin2Cam hardware validation

1. Connect powered USB-C hub to iPad.
2. Connect IPEVO V4K Ultra and JOURIST DC990 to separate USB data ports.
3. Launch Martin2Cam in landscape and grant camera permission.
4. Verify both devices appear independently in both camera selectors.
5. Select IPEVO left and JOURIST right. Confirm both streams remain live simultaneously for 10 minutes.
6. Verify 50:50 geometry and no overlap/cropping at zoom 1x.
7. On each pane test zoom 1x–4x, rotations 0/90/180/270, brightness -1…+1 and contrast 0.5…2.
8. Test AF. Record whether iPadOS exposes continuous/one-shot autofocus for each camera.
9. Test MF slider. Record whether locked focus/lensPosition is exposed and changes optical focus.
10. Disconnect/reconnect each camera and confirm recovery without restarting the app.
11. Record any dropped feed, heat/power issue, latency or crash.

Only after steps 1–10 pass is the build marked hardware-tested.
