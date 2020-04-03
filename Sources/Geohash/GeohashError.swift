/// The errors that can possibly arise when decoding or encoding data using the Geohash algorithm.
///
/// # Reference:
/// [Geohash algorithm](https://en.wikipedia.org/wiki/Geohash)
public enum GeohashError: Error {
    /// Thrown when the input string is empty.
    case emptyInput
    
    /// Thrown when the string contains invalid characters.
    ///
    /// Valid characters are all numbers and all lowercase letters except for *a*, *i*, *l*, *o*.
    case invalidCharacters
    
    /// Thrown when the coordinates are invalid.
    ///
    /// Valid coordinates have a latitude between *-90.0* and *+90.0* and a longitude between *-180.0*
    /// and *+180.0*.
    case invalidCoordinates
}
