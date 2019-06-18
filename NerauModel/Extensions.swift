import Foundation

extension CGPoint {
    public func within(_ otherPoint: CGPoint, diameter: CGFloat) -> Bool {
        return (otherPoint.x - diameter/2.0) < self.x &&
            (otherPoint.x + diameter/2.0) > self.x &&
            (otherPoint.y - diameter/2.0) < self.y &&
            (otherPoint.y + diameter/2.0) > self.y
    }
    
    public func frame(with diameter: CGFloat) -> CGRect {
        return CGRect(x: x - diameter/2, y: y-diameter/2, width: diameter, height: diameter)
    }
}

