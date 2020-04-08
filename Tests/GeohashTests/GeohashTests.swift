import XCTest
@testable import Geohash

final class GeohashTests: XCTestCase {
    
    // MARK: - Bounds tests
    
    func testBounds() throws {
        let hash = "u4pruydqq"
        
        let bounds = try Geohash.bounds(of: hash)
        
        XCTAssertEqual(bounds.upper.latitude, 57.64912, accuracy: 0.001)
        XCTAssertEqual(bounds.lower.latitude, 57.64908, accuracy: 0.001)
        
        XCTAssertEqual(bounds.upper.longitude, 10.40744, accuracy: 0.001)
        XCTAssertEqual(bounds.lower.longitude, 10.40740, accuracy: 0.001)
    }
    
    func testBoundsThrowsWhenHashEmpty() {
        let hash = ""
        
        XCTAssertThrowsError(
            try Geohash.bounds(of: hash),
            "Should not decode empty hashes."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.emptyInput)
        }
    }
    
    func testBoundsThrowsWhenCharacterInvalid() {
        let hash = "aaaaa" // The "a" character is invalid
        
        XCTAssertThrowsError(
            try Geohash.bounds(of: hash),
            "Should not decode invalid characters."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.invalidCharacters)
        }
    }
    
    // MARK: - Decoding tests

    func testDecode() throws {
        let hash = "u4pruydqqvj8pr9yc27rjr"
        
        let coordinates = try Geohash.decode(hash)
        
        XCTAssertEqual(coordinates.latitude, 57.64911, accuracy: 0.001)
        XCTAssertEqual(coordinates.longitude, 10.40744, accuracy: 0.001)
    }
    
    func testDecodeThrowsWhenHashEmpty() {
        let hash = ""
        
        XCTAssertThrowsError(
            try Geohash.decode(hash),
            "Should not decode empty hashes."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.emptyInput)
        }
    }
    
    func testDecodeThrowsWhenCharacterInvalid() {
        let hash = "aaaaa" // The "a" character is invalid
        
        XCTAssertThrowsError(
            try Geohash.decode(hash),
            "Should not decode invalid characters."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.invalidCharacters)
        }
    }
    
    // MARK: - Encoding tests
    
    func testEncode() throws {
        let latitude = 57.64911
        let longitude = 10.40744
        
        let hash = try Geohash.encode(latitude: latitude, longitude: longitude)
        
        XCTAssertEqual(hash, "u4pru")
    }
    
    func testEncodeCustomPrecision() throws {
        let latitude = 57.64911
        let longitude = 10.40744
        
        let hash = try Geohash.encode(
            latitude: latitude,
            longitude: longitude,
            precision: .custom(value: 7)
        )
        
        XCTAssertEqual(hash, "u4pruyd")
    }
    
    func testEncodeThrowsWhenCoordinatesInvalid() {
        let latitude = 576.4911
        let longitude = 10.40744
        
        XCTAssertThrowsError(
            try Geohash.encode(latitude: latitude, longitude: longitude),
            "Should not encode invalid coordinates."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.invalidCoordinates)
        }
    }
    
    // MARK: - Neighbors tests
    
    func testNeighbor() throws {
        let hash = "u4pru"
        
        let neighbor = try Geohash.neighbor(of: hash, direction: .north)
        
        XCTAssertEqual(neighbor, "u4r2h")
    }
    
    func testNeighborThrowsWhenHashEmpty() {
        let hash = ""
        
        XCTAssertThrowsError(
            try Geohash.neighbor(of: hash, direction: .north),
            "Should not decode empty hashes."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.emptyInput)
        }
    }
    
    func testNeighborThrowsWhenCharacterInvalid() {
        let hash = "aaaaa" // The "a" character is invalid
        
        XCTAssertThrowsError(
            try Geohash.neighbor(of: hash, direction: .north),
            "Should not decode invalid characters."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.invalidCharacters)
        }
    }
    
    func testNeighbors() throws {
        let hash = "u4pru"
        
        let neighbors = try Geohash.neighbors(of: hash)
        
        XCTAssertEqual(neighbors.count, 8)
        XCTAssertFalse(neighbors.contains(hash))
        XCTAssertEqual(neighbors, [
            "u4r2h", // n
            "u4r2j", // ne
            "u4prv", // e
            "u4prt", // se
            "u4prs", // s
            "u4pre", // sw
            "u4prg", // w
            "u4r25", // nw
        ])
    }
    
    func testNeighborsIncludingCenter() throws {
        let hash = "u4pru"
        
        let neighbors = try Geohash.neighbors(of: hash, includingCenter: true)
        
        XCTAssertEqual(neighbors.count, 9)
        XCTAssertTrue(neighbors.contains(hash))
        XCTAssertEqual(neighbors, [
            "u4r2h", // n
            "u4r2j", // ne
            "u4prv", // e
            "u4prt", // se
            "u4prs", // s
            "u4pre", // sw
            "u4prg", // w
            "u4r25", // nw
            "u4pru", // center
        ])
    }
    
    func testNeighborsEdgeCase() throws {
        let hash = "u0000"
        
        let neighbors = try Geohash.neighbors(of: hash)
        
        XCTAssertEqual(neighbors, [
            "u0002", // n
            "u0003", // ne
            "u0001", // e
            "spbpc", // se
            "spbpb", // s
            "ezzzz", // sw
            "gbpbp", // w
            "gbpbr", // nw
        ])
    }
    
    func testNeighborsThrowsWhenHashEmpty() {
        let hash = ""
        
        XCTAssertThrowsError(
            try Geohash.neighbors(of: hash),
            "Should not decode empty hashes."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.emptyInput)
        }
    }
    
    func testNeighborsThrowsWhenCharacterInvalid() {
        let hash = "aaaaa" // The "a" character is invalid
        
        XCTAssertThrowsError(
            try Geohash.neighbors(of: hash),
            "Should not decode invalid characters."
        ) { error in
            XCTAssertEqual(error as? GeohashError, GeohashError.invalidCharacters)
        }
    }
}
