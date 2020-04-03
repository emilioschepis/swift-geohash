/// Encodes and decodes coordinates using the Geohash algorithm.
///
/// # Reference:
/// [Geohash algorithm](https://en.wikipedia.org/wiki/Geohash)
public struct Geohash {
    
    private static let values = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    
    // MARK: - Public methods
    
    /// Transforms a string into bounds through the Geohash algorithm.
    ///
    /// A longer string results in smaller bounds.
    /// This methods returns the upper and lower values of the bound.
    /// The string must be a set of valid characters (all numbers and all lowercase letters except for *a*,
    /// *i*, *l*, *o*).
    ///
    /// # Reference:
    /// [Geohash algorithm](https://en.wikipedia.org/wiki/Geohash)
    ///
    /// - Parameter hash: the string to decode.
    /// - Throws: `GeohashError.invalidCharacters` when the string
    /// contains invalid characters.
    /// - Returns: Bounds for the given string.
    public static func bounds(for hash: String) throws -> (
        lower: (latitude: Double, longitude: Double),
        upper: (latitude: Double, longitude: Double)
    ) {
        var latitudeRange = (lower: -90.0, upper: 90.0)
        var longitudeRange = (lower: -180.0, upper: 180.0)
        
        var even = true
        
        for character in hash {
            guard let index = values.firstIndex(of: character) else {
                throw GeohashError.invalidCharacters
            }
            
            var bit = 0b10000 // 2^5 = 32
            
            while bit != 0b00000 {
                if even {
                    let average = (longitudeRange.0 + longitudeRange.1) / 2
                    if index & bit != 0 {
                        longitudeRange.lower = average
                    } else {
                        longitudeRange.upper = average
                    }
                } else {
                    let average = (latitudeRange.0 + latitudeRange.1) / 2
                    if index & bit != 0 {
                        latitudeRange.lower = average
                    } else {
                        latitudeRange.upper = average
                    }
                }
                
                bit >>= 1
                even.toggle()
            }
        }
        
        return (
            lower: (latitudeRange.lower, longitudeRange.lower),
            upper: (latitudeRange.upper, longitudeRange.upper)
        )
    }
    
    /// Transforms a string into coordinates through the Geohash algorithm.
    ///
    /// A longer string results in more accurate coordinates.
    /// This methods returns the center point of the calculated bounding box.
    /// The string must be a set of valid characters (all numbers and all lowercase letters except for *a*,
    /// *i*, *l*, *o*).
    ///
    /// # Reference:
    /// [Geohash algorithm](https://en.wikipedia.org/wiki/Geohash)
    ///
    /// - Parameter hash: the string to decode.
    /// - Throws: `GeohashError.invalidCharacters` when the string
    /// contains invalid characters.
    /// - Returns: Latitude and longitude for the given string.
    public static func decode(_ hash: String) throws -> (
        latitude: Double,
        longitude: Double
    ) {
        let bounds = try Self.bounds(for: hash)
        
        return (
            latitude: (bounds.upper.latitude + bounds.lower.latitude) / 2,
            longitude: (bounds.upper.longitude + bounds.lower.longitude) / 2
        )
    }
    
    /// Transforms latitude and longitude into a hashed string through the Geohash algorithm.
    ///
    /// # Reference:
    /// [Geohash algorithm](https://en.wikipedia.org/wiki/Geohash)
    ///
    /// - SeeAlso: `Precision`
    ///
    /// - Parameter latitude: the latitude of the point of interest.
    /// - Parameter longitude: the longitude of the point of interest.
    /// - Parameter precision: how precisely the coordinates are encoded. More precision requires
    /// more time and generates a longer string.
    /// - Throws: `GeohashError.invalidCoordinates` when the latitude is not between
    /// *-90.0* and *+90.0* or when the longitude is not between *-180.0* and *+180.0*
    /// - Returns: The string representation of the coordinates.
    public static func encode(
        latitude: Double,
        longitude: Double,
        precision: Precision = .medium
    ) throws -> String {
        var hash = ""
        var latitudeRange = (lower: -90.0, upper: 90.0)
        var longitudeRange = (lower: -180.0, upper: 180.0)
        
        guard (latitudeRange.0...latitudeRange.1).contains(latitude) else {
            throw GeohashError.invalidCoordinates
        }
        
        guard (longitudeRange.0...longitudeRange.1).contains(latitude) else {
            throw GeohashError.invalidCoordinates
        }
        
        var bit = 0b10000 // 2^5 = 32
        var index = 0
        var even = true
        
        while hash.count < precision.value {
            if even {
                let average = (longitudeRange.0 + longitudeRange.1) / 2
                if longitude >= average {
                    longitudeRange.lower = average
                    index |= bit
                } else {
                    longitudeRange.upper = average
                }
            } else {
                let average = (latitudeRange.0 + latitudeRange.1) / 2
                if latitude >= average {
                    latitudeRange.lower = average
                    index |= bit
                } else {
                    latitudeRange.upper = average
                }
            }
            
            bit >>= 1
            even.toggle()
            
            if bit == 0b00000 {
                hash.append(values[index])
                bit = 0b10000
                index = 0
            }
        }
        
        return hash
    }
}
