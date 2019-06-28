import UIKit
import NerauModel

class TrainingViewController: UIViewController {
    
    private var controlsViewController: TrainingControlsTableViewController?
    @IBOutlet weak var closeButton: UIButton?
    
    #if targetEnvironment(UIKitForMac)
    let SliderTouchBarItemIdentifier = NSTouchBarItem.Identifier(rawValue: "SliderItem")
    let OkButttonTouchBarItemIdentifer = NSTouchBarItem.Identifier(rawValue: "OkButton")
    let CancelButtonTouchBarItemIdentifier = NSTouchBarItem.Identifier(rawValue: "CancelButton")
    let ActionGroupTouchBarItemIdentifier = NSTouchBarItem.Identifier(rawValue: "Group")
    #endif
    
    override var keyCommands: [UIKeyCommand]? {
        return [UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(doCancelCommand(sender:))),
                UIKeyCommand(input: "\r", modifierFlags: [UIKeyModifierFlags.command], action: #selector(doBeginCommand(sender:)))
        ]
    }
    
    @IBAction func doBeginTraining(sender: UIButton?) {
        guard let config = controlsViewController?.calculatedConfiguration else { return }
        beginTrainingWithConfiguration(configuration: config)
    }
    
    @IBAction func doCancelCommand(sender: Any?) {
        cleanup()
    }
    
    @objc func doBeginCommand(sender: UIKeyCommand) {
        doBeginTraining(sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        closeButton?.isHidden = false
        #endif
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
        
        #if targetEnvironment(UIKitForMac)
        self.touchBar = makeTouchBar()
        
        controlsViewController?.sliderChange = { [weak self] in
            self?.touchBar = self?.makeTouchBar()
        }
        #endif
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
    
    #if targetEnvironment(UIKitForMac)
    @objc func didUpdateTouchbarSlider(slider: NSSliderTouchBarItem) {
        if let value = slider.value(forKeyPath: "slider.intValue") as? Int {
            controlsViewController?.updateSlider(with: CGFloat(value))
        }
    }
    #endif
    
    @objc func touchBarBegin(sender: Any) {
        doBeginTraining(sender: nil)
    }
    
    @objc func touchBarCancel(sender: Any) {
        cleanup()
    }
    
    private func cleanup() {
        #if targetEnvironment(UIKitForMac)
        self.touchBar = nil
        setNeedsTouchBarUpdate()
        #endif
        controlsViewController?.dismiss(animated: true, completion: nil)
        dismiss(animated: false)
        controlsViewController = nil
    }
}

extension TrainingViewController: TrainControllerDelegate {
    func didFinishTraining(result: TrainResult, controller: TrainController) {
        controller.dismiss(animated: true) {
            self.cleanup()
            guard let wrappingController = self.storyboard?.instantiateViewController(identifier: "ResultWrapper")
                as? ResultWrappingController
                else { return }
            wrappingController.result = result
            self.presentingViewController?.present(wrappingController, animated: true, completion: nil)
        }
    }
    
    func didCancelTraining(controller: TrainController) {
        cleanup()
    }
}

#if targetEnvironment(UIKitForMac)
extension TrainingViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [
            SliderTouchBarItemIdentifier,
            ActionGroupTouchBarItemIdentifier
        ]
        touchBar.principalItemIdentifier = ActionGroupTouchBarItemIdentifier
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
        case ActionGroupTouchBarItemIdentifier:
            let firstItem = NSButtonTouchBarItem(identifier: OkButttonTouchBarItemIdentifer, title: "Begin", target: self, action: #selector(touchBarBegin))
            firstItem.bezelColor = UIColor.systemBlue
            let secondItem = NSButtonTouchBarItem(identifier: CancelButtonTouchBarItemIdentifier, title: "Cancel", target: self, action: #selector(touchBarCancel))
            secondItem.bezelColor = UIColor.systemRed
            let group = NSGroupTouchBarItem(alertStyleWithIdentifier: identifier)
            group.groupTouchBar.templateItems = [firstItem, secondItem]
            group.groupTouchBar.defaultItemIdentifiers = [OkButttonTouchBarItemIdentifer, CancelButtonTouchBarItemIdentifier]
            return group
        default: return nil
        }
    }
}

#endif
