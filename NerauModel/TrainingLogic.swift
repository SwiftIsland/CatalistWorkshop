import Foundation


public enum TrainLogicError: Error {
    case message(String)
}

public struct TrainingLogic {
    /// Calculate a random letter distribution to use as the basis for the train views.
    /// This will return a list of random characters plus their x/y coordinates, plus a list of "hit" characters and their
    /// coordinates. These are the characters that the user has to "hit"
    /// - parameter validCharacters: The characters that are allowed in the distribution, i.e. 0-9 or A-F
    /// - parameter totalNumber: The total number of characters to generate (minus the `hitCharacters`)
    /// - parameter hitCharacters: The total number of the character that the user has to hit.
    ///   Here, `count` is the number of times the user has to hit the character, `characters` are the different characters
    ///   that we're randomly choosing from: A `(3, ["a", "b"])` could result in `aab` or `bab`, or `bba`, etc.
    /// - parameter dimensions: The total dimension of the space to place the characters in. Notably, will leave a safe area
    public static func weightedNumberDistribution(validCharacters: [Character],
                                                  totalNumber: Int,
                                                  hitCharacters: (count: Int, characters: [Character]),
                                                  dimensions: CGSize) throws -> (
        characters: [(character: Character, position: CGPoint)],
        hitCharacters: [(character: Character, position: CGPoint)]
        ) {
            let randomValidCharacters = (0..<totalNumber).compactMap { _ in validCharacters.randomElement() }
            let randomHitCharacters = (0..<hitCharacters.count).compactMap { _ in hitCharacters.characters.randomElement() }
            /// the safe area is the area at the corners
            let safeArea: CGFloat = 100
            guard dimensions.width > safeArea*2,
                dimensions.height > safeArea*2 else {
                    throw TrainLogicError.message("Device is too small")
            }
            let dims = (w: Int(safeArea)..<(Int(dimensions.width - safeArea)),
                        h: Int(safeArea)..<(Int(dimensions.height - safeArea)))
            let distributeCharacters = { (characters: [Character],
                overlays: [(Character, CGPoint)],
                tapTargetSize: CGFloat) -> [(Character, CGPoint)] in
                /// place all characters on a grid while making sure that we're never overlapping by less
                /// than half a tap target. Also, return early if we're out of space to prevent infinite loops
                var map = [(Character, CGPoint)]()
                
                /// Sure, this is slow as hell, but we don't have an A12 for nothing
                for character in characters {
                    var maxIterations = 1000
                    outer: while true {
                        maxIterations -= 1
                        guard maxIterations > 0 else { return map }
                        let position = CGPoint(x: dims.w.randomElement()!,
                                               y: dims.h.randomElement()!)
                        for (_, point) in map {
                            if position.within(point, diameter: tapTargetSize) {
                                continue outer
                            }
                        }
                        if !overlays.isEmpty {
                            for (_, point) in map {
                                if position.within(point, diameter: tapTargetSize/2) {
                                    continue outer
                                }
                            }
                        }
                        map.append((character, position))
                        break
                    }
                }
                return map
            }
            /// The valid chars are not tappable, so they can be closer to each other
            /// the hit chars overlay the valid chars, so we need them as a reference to not overlay
            let validChars = distributeCharacters(randomValidCharacters, [], tapTargetSize/2.0)
            let hitChars = distributeCharacters(randomHitCharacters, validChars, tapTargetSize)
            return (validChars, hitChars)
    }
    
    public static func calculateMap(from hits: [TrainResult.ResultEntry], canvas: CGSize) -> [Double] {
        var map = [Double].init(repeating: 0.0,
                                count: TrainResult.mapSize.0 * TrainResult.mapSize.1)
        /// we need a least two entries
        guard hits.count > 2 else { return map }
        /// the difference between the longest and shortest time maps our duration
        let sorted = hits.map({ $0.1 }).sorted()
        let shortest = sorted[0]
        let longest = sorted[sorted.count - 1]
        for (point, interval) in hits {
            let value = (interval - shortest) / (longest - shortest)
            let x = Int(point.x / canvas.width * CGFloat(TrainResult.mapSize.0))
            let y = Int(point.y / canvas.height * CGFloat(TrainResult.mapSize.1))
            map[y * TrainResult.mapSize.0 + x] = value
        }
        return map
    }
    
    public static var tapTargetSize: CGFloat {
        return 44.0
    }
}
