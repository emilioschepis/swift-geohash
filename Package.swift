// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swift-geohash",
    products: [
        .library(name: "Geohash", targets: ["Geohash"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "Geohash", dependencies: []),
        .testTarget(name: "GeohashTests", dependencies: ["Geohash"]),
    ]
)
