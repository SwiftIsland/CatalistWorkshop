import ARKit
import NerauModel

/// Imagine the numbers are laid out in a room and one has to move
/// the iPad around to tap them in the room. 
final class TrainViewAR: UIView {
    public weak var delegate: TrainViewDelegate?
    let arView = ARSCNView(frame: CGRect.zero)
}

extension TrainViewAR: TrainControlViewProtocol {
    public func prepare(with configuration: TrainConfiguration) {
        addSubview(arView)
    }
    
    public func setupCharacters(configuration: TrainConfiguration) {
    }
    
    public func beginTraining() {
    }
    
    public func startupMessage() -> String {
        return "Not done yet"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.cancel(with: "Ooopsie")
    }
}
