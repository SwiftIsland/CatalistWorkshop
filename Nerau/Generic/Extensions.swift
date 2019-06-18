import Foundation

private let humanReadableFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    formatter.maximumUnitCount = 0
    formatter.allowedUnits = [.minute, .second]
    return formatter
}()

extension TimeInterval {
    var humanReadable: String {
        return humanReadableFormatter.string(from: self) ?? "Invalid"
    }
}
