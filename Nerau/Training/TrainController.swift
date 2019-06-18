import UIKit
import NerauModel

public protocol TrainControllerDelegate: class {
    func didFinishTraining(result: TrainResult, controller: TrainController)
    func didCancelTraining(controller: TrainController)
}

public protocol TrainControlViewProtocol {
    var delegate: TrainViewDelegate? { get set }
    func prepare(with configuration: TrainConfiguration)
    func setupCharacters(configuration: TrainConfiguration)
    func beginTraining()
    func startupMessage() -> String
}

public final class TrainController: UIViewController {

    public var delegate: TrainControllerDelegate?

    private var configuration: TrainConfiguration
    private var controlView: TrainControlViewProtocol & UIView

    public init(configuration: TrainConfiguration) {
        self.configuration = configuration
        switch configuration.mode {
        case .AR: controlView = TrainViewAR()
        case .normal: controlView = TrainViewNormal()
        }
        super.init(nibName: nil, bundle: nil)
        controlView.prepare(with: configuration)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startupMessage() -> String {
        return controlView.startupMessage()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        controlView.delegate = self
        controlView.backgroundColor = UIColor.white
        controlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlView)
        NSLayoutConstraint.activate([
            controlView.leftAnchor.constraint(equalTo: view.leftAnchor),
            controlView.rightAnchor.constraint(equalTo: view.rightAnchor),
            controlView.topAnchor.constraint(equalTo: view.topAnchor),
            controlView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        controlView.frame = view.bounds
        controlView.setupCharacters(configuration: configuration)
        controlView.beginTraining()
    }
}

extension TrainController: TrainViewDelegate {
    public func cancel(with message: String) {
        delegate?.didCancelTraining(controller: self)
    }

    public func finish(with result: [TrainResult.ResultEntry], size: CGSize, duration: TimeInterval) {
        let map = TrainingLogic.calculateMap(from: result, canvas: size)
        var result = TrainResult(configuration: self.configuration, duration: duration, strengthMap: map, durations: result)
        Database.shared.saveTrainResult(&result)
        delegate?.didFinishTraining(result: result, controller: self)
    }
}
