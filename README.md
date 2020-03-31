# Geohash

Implementation of the Geohash algorithm in Swift.

Distributed through Swift Package Manager.

![](https://github.com/emilioschepis/swift-geohash/workflows/test/badge.svg)

## Install
```swift
// Package.swift

// ...
dependencies: [
    // ...
    .package(url: "https://github.com/emilioschepis/swift-geohash.git", from: "1.0.0"),
]
// ...
```

## Methods

### Decode
```swift
try Geohash.decode("u4prs") // (latitude: 57.6..., longitude: 10.4...)
```

### Encode
```swift
try Geohash.encode(latitude: 57.6, longitude: 10.4) // "u4prs"
```

```swift
try Geohash.encode(latitude: 57.6, longitude: 10.4, precision: .high) // "u4prstv"
```

```swift
try Geohash.encode(latitude: 57.6, longitude: 10.4, precision: .custom(9)) // "u4prstv03"
```

## Resources
- [Geohash](https://en.wikipedia.org/wiki/Geohash)
- [Geohash.js](https://github.com/davetroy/geohash-js)
- [GeohashKit](https://github.com/maximveksler/GeohashKit)
