import UIKit
import NerauModel

final class TrainingControlsTableViewController: UITableViewController {
    
    var calculatedConfiguration: TrainConfiguration {
        let difficulty = TrainConfiguration.Difficulty(rawValue: difficultyPicker.selectedRow(inComponent: 0))!
        let mode = TrainConfiguration.Mode(rawValue: modeSelector.selectedSegmentIndex)!
        let config = TrainConfiguration(difficulty: difficulty, length: Int(lengthSlider.value), mode: mode)
        return config
    }
    
    @IBOutlet var difficultyPicker: UIPickerView!
    @IBOutlet var modeSelector: UISegmentedControl!
    @IBOutlet var lengthSlider: UISlider!
    @IBOutlet var lengthLabel: UILabel!
    
    var sliderChange: (() -> Void)?
    
    private let difficultyValues = TrainConfiguration.Difficulty.allCases.map { ($0.name, $0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        difficultyPicker.delegate = self
        difficultyPicker.dataSource = self
        lengthSlider.addTarget(self, action: #selector(self.didUpdateSlider(slider:)), for: .valueChanged)
        didUpdateSlider(slider: lengthSlider)
    }
    
    @objc func didUpdateSlider(slider: UISlider) {
        lengthLabel.text = "\(Int(slider.value)) numbers"
        sliderChange?()
    }
    
    func updateSlider(with value: CGFloat) {
        lengthSlider.value = Float(value)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if targetEnvironment(UIKitForMac)
        if (indexPath.row == 0) {
            return 0.0
        }
        #endif
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}



extension TrainingControlsTableViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
        return difficultyValues[row].0
    }
}

extension TrainingControlsTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return difficultyValues.count
    }
}

