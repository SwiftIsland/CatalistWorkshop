import UIKit
import NerauModel

public protocol TrainViewDelegate: class {
    func cancel(with message: String)
    func finish(with result: [TrainResult.ResultEntry], size: CGSize, duration: TimeInterval)
}

final public class TrainViewNormal: UIView {

    public weak var delegate: TrainViewDelegate?

    private var hitViews: [UIButton] = []
    private var resultHits: [TrainResult.ResultEntry] = []

    private var beginTrainingTime: Date?
    private var currentTrainingTime: Date?
    
    private var characters: [Character] = []
    private var hitCharacter: Character = " "

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    @objc func didTapButton(sender: UIButton) {
        guard let trainingTime = currentTrainingTime,
            let beginTime = beginTrainingTime else { return }
        let diff = Date().timeIntervalSince(trainingTime)
        hitViews.removeAll(where: { $0 == sender })
        sender.removeFromSuperview()
        resultHits.append((sender.frame.origin, diff))
        if hitViews.isEmpty {
            delegate?.finish(with: resultHits,
                             size: frame.size,
                             duration: Date().timeIntervalSince(beginTime))
        }
        currentTrainingTime = Date()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count >= 2 {
            delegate?.cancel(with: "User Quit")
        }
    }
}

extension TrainViewNormal {
    func characterButton(character: Character, point: CGPoint, font: UIFont) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle("\(character)", for: .normal)
        button.frame = point.frame(with: TrainingLogic.tapTargetSize)
        button.titleLabel?.font = font
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        return button
    }
    
    func characterLabel(character: Character, point: CGPoint, font: UIFont) -> UILabel {
        let label = UILabel(frame: point.frame(with: TrainingLogic.tapTargetSize))
        label.text = "\(character)"
        label.font = font
        return label
    }
}

extension TrainViewNormal: TrainControlViewProtocol {
    public func prepare(with configuration: TrainConfiguration) {
        characters = configuration.validCharacters
        /// split up into two sets
        hitCharacter = characters.randomElement()!
        characters.removeAll(where: { $0 == hitCharacter })
        isMultipleTouchEnabled = true
    }
    
    public func setupCharacters(configuration: TrainConfiguration) {
        do {
            let (valid, hit) = try TrainingLogic.weightedNumberDistribution(
                validCharacters: characters,
                totalNumber: configuration.totalCharacterCount,
                hitCharacters: (count: configuration.length, characters: [hitCharacter]),
                dimensions: frame.size)

            for (character, point) in valid {
                addSubview(characterButton(character: character, point: point, font: configuration.font))
            }
            for (character, point) in hit {
                let button = characterButton(character: character, point: point, font: configuration.font)
                addSubview(button)
                button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchDown)
                hitViews.append(button)
            }
        } catch TrainLogicError.message(let msg) {
            delegate?.cancel(with: msg)
        } catch {
            delegate?.cancel(with: "Invalid Error")
        }
        
        let label = UILabel()
        label.text = "Touch with 2 fingers to cancel"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
            ])
    }
    
    public func beginTraining() {
        currentTrainingTime = Date()
        beginTrainingTime = Date()
    }
    
    public func startupMessage() -> String {
        return NSLocalizedString("Find the following letter:\n\n\(hitCharacter)",
            comment: "This message is displayed when starting a default session")
    }
}
