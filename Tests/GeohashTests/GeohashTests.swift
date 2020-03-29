import XCTest
@testable import Geohash

final class GeohashTests: XCTestCase {
    
    // MARK: - Decoding tests

    func testDecode() throws {
        let hash = "u4pruydqqvj8pr9yc27rjr"
        
        let coordinates = try Geohash.decode(hash)
        
        XCTAssertEqual(coordinates.latitude, 57.64911, accuracy: 0.001)
        XCTAssertEqual(coordinates.longitude, 10.40744, accuracy: 0.001)
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
}
