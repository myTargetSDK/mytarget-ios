// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "MyTargetSDK",
	platforms:
	[
		.iOS(.v9)
	],
	products:
	[
		.library(
			name: "MyTargetSDK",
			targets: ["MyTargetSDK"]),
	],
	targets:
	[
		.binaryTarget(name: "MyTargetSDK",
					  path: "Binary/MyTargetSDK.xcframework"),
	]
)
