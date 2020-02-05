# 2019-09-03 -- v0.18.0
- Bug fixes.

# 2019-07-09 -- v0.17.0
- Fixed the known issue of `VisionObjectDetector` where in streaming mode, if the category of an object changes, the detector assigns it a new tracking ID.
- Improved detecting small objects with `VisionObjectDetector`.
- {breaking change} Removed `entityID` and `label` APIs from `VisionObject`.

# 2019-05-07 -- v0.16.0
- Initial release of on-device Object Detection and Tracking API.
