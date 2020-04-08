/// Encodes and decodes coordinates using the Geohash algorithm.
///
/// # Reference:
/// [Geohash algorithm](https://en.wikipedia.org/wiki/Geohash)
public struct Geohash {
    
    public typealias Coordinates = (latitude: Double, longitude: Double)
    public typealias Bounds = (lower: Coordinates, upper: Coordinates)
    
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
    public static func bounds(of hash: String) throws -> Bounds {
        var latitudeRange = (lower: -90.0, upper: 90.0)
        var longitudeRange = (lower: -180.0, upper: 180.0)
        
        var even = true
        
        guard !hash.isEmpty else {
            throw GeohashError.emptyInput
        }
        
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
    public static func decode(_ hash: String) throws -> Coordinates {
        let bounds = try Self.bounds(of: hash)
        
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
    
    /// Calculates the hash of the neighbor in a given direction for a given hash.
    ///
    /// - Parameter hash: the original hash.
    /// - Parameter direction: the compass point representing the direction.
    /// - Throws: `GeohashError.invalidCharacters` when the string
    /// contains invalid characters.
    /// - Returns: The hash of the calculated neighbor.
    public static func neighbor(
        of hash: String,
        direction: CompassPoint
    ) throws -> String {
        let bounds = try Self.bounds(of: hash)
        let precision = Precision.custom(value: hash.count)
        
        return try neighbor(from: bounds,
                            direction: direction,
                            precision: precision)
    }
    
    /// Calculates the hashes of all neighbors for a given hash.
    ///
    /// The neighbors are returned in clockwise order.
    /// If the center is included it is returned as the last element.
    ///
    /// 7 0 1
    ///
    /// 6 8 2
    ///
    /// 5 4 3
    ///
    /// - Parameter hash: the original hash.
    /// - Parameter includingCenter: whether or not the source hash is included in the neighbors.
    /// - Throws: `GeohashError.invalidCharacters` when the string
    /// contains invalid characters.
    /// - Returns: The hashes of the calculated neighbors.
    public static func neighbors(of hash: String, includingCenter: Bool = false) throws -> [String] {
        let bounds = try Self.bounds(of: hash)
        let precision = Precision.custom(value: hash.count)
        
        var neighbors = [
            try neighbor(from: bounds,
                         direction: .north,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .northEast,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .east,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .southEast,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .south,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .southWest,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .west,
                         precision: precision),
            try neighbor(from: bounds,
                         direction: .northWest,
                         precision: precision),
        ]
        
        if includingCenter {
            neighbors.append(hash)
        }
        
        return neighbors
    }
    
    // MARK: - Private methods
    
    private static func neighbor(
        from bounds: Bounds,
        direction: CompassPoint,
        precision: Precision
    ) throws -> String {
        // The center point of the bounds
        let center = (
            latitude: (bounds.upper.latitude + bounds.lower.latitude) / 2,
            longitude: (bounds.upper.longitude + bounds.lower.longitude) / 2
        )
        
        // The difference between upper and lower bound
        // Used to calculate the precision of the coordinates
        let delta = (
            latitude: bounds.upper.latitude - bounds.lower.latitude,
            longitude: bounds.upper.longitude - bounds.lower.longitude
        )
        
        // The coordinates of the neighbor calculated multiplying the delta for
        // the multiplier (e.g. north is 1x the latitude and 0x the longitude)
        let coordinates = (
            latitude: center.latitude +
                delta.latitude * direction.deltaMultiplier.latitude,
            longitude: center.longitude +
                delta.longitude * direction.deltaMultiplier.longitude
        )
        
        return try encode(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            precision: precision)
    }
}
