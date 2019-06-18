import Foundation
import CoreData

public struct TrainResult {
    public typealias ResultEntry = (CGPoint, TimeInterval)
    
    public static var mapSize: (Int, Int) = (32, 32)
    /// If this result is stored, we keep the identifier here
    internal var objectIdentifier: NSManagedObjectID?
    /// Is this a stored result
    public var isStored: Bool {
        return objectIdentifier != nil
    }
    /// The initial configuration
    public var configuration: TrainConfiguration
    /// The duration of the session
    public var duration: TimeInterval
    /// A 32x32 2D map showing which areas were more problematic for the user
    /// each entry is a Double 0.0 - 1.0 where 1.0 is the best result
    public var strengthMap: [Double]
    /// The individual durations and points
    public var durationPoints: [ResultEntry]
    /// When was this taken
    public var date: Date
    /// Did we star this
    public var stared: Bool = false
    
    public init(configuration: TrainConfiguration, duration: TimeInterval, strengthMap: [Double], durations: [ResultEntry]) {
        self.configuration = configuration
        self.duration = duration
        self.strengthMap = strengthMap
        self.durationPoints = durations
        self.date = Date()
    }
}
