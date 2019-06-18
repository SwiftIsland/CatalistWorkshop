import Foundation

public struct TrainConfiguration {
    public enum Difficulty: Int, CaseIterable {
        case easy, medium, hard, insane
    }
    public enum Mode: Int {
        case normal, AR
    }
    public var difficulty: Difficulty
    public var length: Int
    public var mode: Mode
    
    public init(difficulty: Difficulty, length: Int, mode: Mode) {
        self.difficulty = difficulty
        self.length = length
        self.mode = mode
    }
}

extension TrainConfiguration {
    public var validCharacters: [Character] {
        let sets = (
            numbers: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] as [Character],
            bigLetters: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"] as [Character],
            smallLetters: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n"] as [Character]
        )
        switch self.difficulty {
        case .easy: return sets.numbers
        case .medium: return sets.bigLetters
        case .hard: return sets.smallLetters + sets.bigLetters
        case .insane: return sets.numbers + sets.smallLetters + sets.bigLetters
        }
    }
    
    public var totalCharacterCount: Int {
        switch self.difficulty {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        case .insane: return 40
        }
    }
    
    public var font: UIFont {
        return UIFont.systemFont(ofSize: 17.0)
    }
}
