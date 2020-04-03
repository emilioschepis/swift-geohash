/// Represents a compass point
public enum CompassPoint {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest
    
    internal var deltaMultiplier: (latitude: Double, longitude: Double) {
        switch self {
        case .north:
            return (1, 0)
        case .northEast:
            return (1, 1)
        case .east:
            return (0, 1)
        case .southEast:
            return (-1, 1)
        case .south:
            return (-1, 0)
        case .southWest:
            return (-1, -1)
        case .west:
            return (0, -1)
        case .northWest:
            return (1, -1)
        }
    }
}
