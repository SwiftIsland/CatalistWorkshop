import UIKit
import NerauModel

class TrainingViewController: UIViewController {
    
    private var controlsViewController: TrainingControlsTableViewController?
    
    let SliderTouchBarItemIdentifier = NSTouchBarItem.Identifier(rawValue: "SliderItem")
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(doCancelCommand(sender:))),
                UIKeyCommand(input: "\r", modifierFlags: [UIKeyModifierFlags.command], action: #selector(doBeginCommand(sender:)))
        ]
    }
    
    @IBAction func doBeginTraining(sender: UIButton?) {
        guard let config = controlsViewController?.calculatedConfiguration else { return }
        beginTrainingWithConfiguration(configuration: config)
    }
    
    @objc func doCancelCommand(sender: UIKeyCommand) {
        controlsViewController?.dismiss(animated: true, completion: nil)
        controlsViewController = nil
    }
    
    @objc func doBeginCommand(sender: UIKeyCommand) {
        doBeginTraining(sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "resultController"?:
            if let resultController = segue.destination as? ResultController {
                resultController.result = sender as? TrainResult
            } else if let wrapController = segue.destination as? ResultWrappingController {
                wrapController.result = sender as? TrainResult
            }
        case "EmbedSegue":
            controlsViewController = segue.destination as? TrainingControlsTableViewController
        default: fatalError("Unknown Segue \(segue.identifier ?? "Anon")")
        }
        
        self.touchBar = makeTouchBar()
        
        controlsViewController?.sliderChange = { [weak self] in
            self?.touchBar = self?.makeTouchBar()
        }
    }
    
    internal func beginTrainingWithConfiguration(configuration: TrainConfiguration) {
        let controller = TrainController(configuration: configuration)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        let alert = UIAlertController(title: "Search For", message: controller.startupMessage(), preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (_) in
            self.present(controller, animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didUpdateTouchbarSlider(slider: NSSliderTouchBarItem) {
        if let value = slider.value(forKeyPath: "slider.intValue") as? Int {
            controlsViewController?.updateSlider(with: CGFloat(value))
        }
    }
}

extension TrainingViewController: TrainControllerDelegate {
    func didFinishTraining(result: TrainResult, controller: TrainController) {
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: "resultController", sender: result)
        }
    }
    
    func didCancelTraining(controller: TrainController) {
        controller.dismiss(animated: true)
    }
}

#if targetEnvironment(UIKitForMac)
extension TrainingViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [
            SliderTouchBarItemIdentifier
        ]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        guard let ctrl = controlsViewController else { return nil }
        // Note: 'NSImageNameTouchBarAddTemplate' is unavailable in UIKit for Mac
        switch identifier {
        case SliderTouchBarItemIdentifier:
            let slider = NSSliderTouchBarItem(identifier: identifier)
            slider.action = #selector(self.didUpdateTouchbarSlider)
            slider.target = self
            slider.label = "Strength"
            slider.setValue(ctrl.lengthSlider.maximumValue, forKeyPath: "slider.maxValue")
            slider.setValue(ctrl.lengthSlider.minimumValue, forKeyPath: "slider.minValue")
            slider.setValue(ctrl.lengthSlider.value, forKeyPath: "slider.intValue")
            return slider
        default: return nil
        }
    }
}

#endif
