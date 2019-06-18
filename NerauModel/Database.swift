import Foundation
import CoreData

public protocol UIErrorHandler: class {
    func displayError(message: String)
}

extension Optional {
    enum UnwrapError: Error {
        case missingValue(String)
    }

    func unwrap(_ message: String) throws -> Wrapped {
        guard let value = self else {
            throw UnwrapError.missingValue(message)
        }
        return value
    }
}

func unwrap<T, W>(_ container: T, _ keyPath: KeyPath<T, Optional<W>>) throws -> W
{
    return try container[keyPath: keyPath].unwrap("\(keyPath) on \(container)")
}


private struct DataContainer: Codable {
    struct DurationEntry: Codable {
        var point: CGPoint
        var duration: Double
    }
    var strengthMap: [Double]
    var durationPoints: [DurationEntry]

    init(result: TrainResult) {
        self.strengthMap = result.strengthMap
        self.durationPoints = result.durationPoints.map { DurationEntry(point: $0.0, duration: $0.1) }
    }
    
    init(map: [Double], points: [DurationEntry]) {
        self.strengthMap = map
        self.durationPoints = points
    }
}

private class BundleTrampoline: NSObject {}

/// A terrible abstraction.
public final class Database {
    
    public static var shared = Database()
    
    private init() {
    }
    
    public struct Selection {
        var timeFrame: (Date, Date)?
        var difficulty: TrainConfiguration.Difficulty?
        var mode: TrainConfiguration.Mode?
        var stared: Bool?
        
        public init(_ from: Date,
                    _ until: Date? = nil) {
            timeFrame = (from, until ?? Date())
            self.difficulty = nil
            self.mode = nil
        }
        
        public init(_ difficulty: TrainConfiguration.Difficulty) {
            self.difficulty = difficulty
        }
        
        public init(_ starred: Bool) {
            self.stared = starred
        }
        
        fileprivate func predicate() -> NSPredicate {
            var predicates = [NSPredicate]()
            if let timeFrame = timeFrame {
                predicates.append(NSPredicate(format: "resultDate > %@ and resultDate < %@", argumentArray: [timeFrame.0, timeFrame.1]))
            }
            if let difficulty = difficulty {
                predicates.append(NSPredicate(format: "configDifficulty = \(difficulty.rawValue)"))
            }
            if let mode = mode {
                predicates.append(NSPredicate(format: "configMode = %i", [mode.rawValue]))
            }
            if let stared = stared {
                predicates.append(NSPredicate(format: "stared == %@", NSNumber(booleanLiteral: stared)))
            }
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
    
    public weak var errorDelegate: UIErrorHandler?
    
    public lazy var persistentContainer: NSPersistentContainer = {
        guard let url = Bundle(for: BundleTrampoline.classForCoder()).url(forResource: "NerauModel", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Missing `NerauModel.momd`") }
        let container = NSPersistentContainer(name: "NerauModel", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private func saveContext () throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    private var changeHandlers: [NSObject: () -> Void] = [:]
    public func registerForChanges<T: NSObject>(item: T, handler: @escaping () -> Void) {
        changeHandlers[item] = handler
    }
    
    public func unregisterForChanges<T: NSObject>(item: T) {
        changeHandlers.removeValue(forKey: item)
    }
    
    private func notify() {
        for (_, h) in changeHandlers {
            h()
        }
    }
    
    /// Stores the `TrainResult` updates the `objectID` on the `TrainResult`
    public func saveTrainResult(_ result: inout TrainResult) {
        process {
            let container = DataContainer(result: result)
            let data = try JSONEncoder().encode(container)
            let entity = NSEntityDescription.entity(forEntityName: "NerauResult", in: persistentContainer.viewContext)!
            let entry = NerauResult(entity: entity, insertInto: persistentContainer.viewContext)
            entry.configDifficulty = Int32(result.configuration.difficulty.rawValue)
            entry.configLength = Int32(result.configuration.length)
            entry.configMode = Int32(result.configuration.mode.rawValue)
            entry.resultDuration = result.duration
            entry.resultDate = result.date
            entry.resultData = data
            entry.stared = result.stared
            persistentContainer.viewContext.insert(entry)
            try saveContext()
            result.objectIdentifier = entry.objectID
            self.notify()
        }
    }

    public func trainResults(selection: Selection) -> [TrainResult] {
        let request: NSFetchRequest<NerauResult> = NSFetchRequest(entityName: "NerauResult")
        request.predicate = selection.predicate()
        request.sortDescriptors = [NSSortDescriptor(key: "resultDate", ascending: false)]
        return (try? {
            let entries = try persistentContainer.viewContext.fetch(request)
            return try entries.map(self.convertTrainResult)
        }()) ?? []
    }
    
    public func numberOfTrainResults(selection: Selection? = nil) -> Int {
        let request: NSFetchRequest<NerauResult> = NSFetchRequest(entityName: "NerauResult")
        request.predicate = selection.map { $0.predicate() }
        return (try? persistentContainer.viewContext.count(for: request)) ?? 0
    }
    
    public func removeResult(result: TrainResult) {
        guard let objectID = result.objectIdentifier else { return }
        process {
            try persistentContainer.viewContext.delete(persistentContainer.viewContext.existingObject(with: objectID))
        }
        notify()
    }
    
    public func toggleStarResult(result: TrainResult) {
        guard let objectID = result.objectIdentifier else { return }
        process {
            try (persistentContainer.viewContext.existingObject(with: objectID) as? NerauResult)?.stared = result.stared
            try saveContext()
            self.notify()
        }
    }
    
    private func process(_ action: () throws -> ()) {
        do {
            try action()
        } catch let error {
            errorDelegate?.displayError(message: error.localizedDescription)
        }
    }
    
    private func convertTrainResult(from result: NerauResult) throws -> TrainResult {
        let container = try JSONDecoder().decode(DataContainer.self,
                                           from: unwrap(result, \.resultData))
        guard let difficulty = TrainConfiguration.Difficulty(rawValue: Int(result.configDifficulty)),
            let mode = TrainConfiguration.Mode(rawValue: Int(result.configMode)) else {
                fatalError("Invalid Values for difficulty or mode in CoreData")
        }
        let configuration = TrainConfiguration(difficulty: difficulty,
                                               length: Int(result.configLength),
                                               mode: mode)
        var trainResult = TrainResult(configuration: configuration,
                                 duration: TimeInterval(result.resultDuration),
                                 strengthMap: container.strengthMap,
                                 durations: container.durationPoints.map { ($0.point, $0.duration) })
        trainResult.date = result.resultDate!
        trainResult.objectIdentifier = result.objectID
        trainResult.stared = result.stared
        return trainResult
    }
    
    /// Need some data for the workshop
    public func generateFakeData(number: Int) {
        let difficulties = 0..<4
        let lengths = 5..<25
        let durations = (10..<120).map(Double.init) // seconds
        let times = (3..<50) // hours
        var startTime = Date()
        let s = (1024, 768)
        for _ in 0..<number {
            let length = lengths.randomElement()!
            var strengthDurationPoints: [Double] = []
            let strengthMap = (0..<(32 * 32)).map { (Int) -> Double in
                guard strengthDurationPoints.count < length else { return 0.0 }
                if (0..<20).randomElement()! > 15 {
                    let value = Double((0..<10).randomElement()!)/10.0
                    strengthDurationPoints.append(value)
                    return value
                } else {
                    return 0.0
                }
            }
            let durationPoints = strengthDurationPoints.map { v in
                return DataContainer.DurationEntry(point: CGPoint(x: Int.random(in: 0..<s.0),
                                                                  y: Int.random(in: 0..<s.1)),
                                                   duration: v * 60.0 + 2.0)
            }
            process {
                let container = DataContainer(map: strengthMap, points: durationPoints)
                let data = try JSONEncoder().encode(container)
                let entry = NerauResult(context: persistentContainer.viewContext)
                entry.configDifficulty = Int32(difficulties.randomElement()!)
                entry.configLength = Int32(length)
                entry.configMode = Int32(0)
                entry.resultDuration = durations.randomElement()!
                entry.resultDate = startTime
                entry.resultData = data
                try saveContext()
            }
            startTime = Date(timeInterval: -1 * (Double(times.randomElement()!) * 3600.0), since: startTime)
        }
    }
}


