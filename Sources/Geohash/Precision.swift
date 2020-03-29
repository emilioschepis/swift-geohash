/// Represents the precision used when encoding coordinates.
///
/// The uncertainty for each precision value is:
/// - 1: (veryLow) -- ± 2500km
/// - 3: (low) -- ± 78km
/// - 5: (medium) -- ± 2.4km
/// - 7: (high) -- ± 0.076km
/// - 9: (veryHigh) -- ± 0.0024km
public enum Precision {
    /// Encodes coordinates using 1 character.
    ///
    /// Has an uncertainty of ± 2500km.
    case veryLow
    
    /// Encodes coordinates using 3 characters.
    ///
    /// Has an uncertainty of ± 78km.
    case low
    
    /// Encodes coordinates using 5 characters.
    ///
    /// Has an uncertainty of ± 2.4km.
    case medium
    
    /// Encodes coordinates using 7 characters.
    ///
    /// Has an uncertainty of ± 0.076km.
    case high
    
    /// Encodes coordinates using 9 characters.
    ///
    /// Has an uncertainty of ± 0.0024km.
    case veryHigh
    
    /// Encodes coordinates using a variable number of characters.
    ///
    /// An higher value results in a more accurante encoding at the cost of time and computational power.
    case custom(value: Int)
    
    internal var value: Int {
        switch self {
        case .veryLow:
            return 1
        case .low:
            return 3
        case .medium:
            return 5
        case .high:
            return 7
        case .veryHigh:
            return 9
        case .custom(let value):
            return value
        }
    }
}
