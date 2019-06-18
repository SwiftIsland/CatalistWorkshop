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
