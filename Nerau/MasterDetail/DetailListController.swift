import UIKit
import NerauModel

extension TrainConfiguration.Difficulty {
    var name: String {
        switch self {
        case .easy:
            return NSLocalizedString("Easy", comment: "Detail Result Table View Difficulty")
        case .medium:
            return NSLocalizedString("Medium", comment: "Detail Result Table View Difficulty")
        case .hard:
            return NSLocalizedString("Hard", comment: "Detail Result Table View Difficulty")
        case .insane:
            return NSLocalizedString("Insane", comment: "Detail Result Table View Difficulty")
        }
    }
}

extension TrainConfiguration.Mode {
    var name: String {
        switch self {
        case .AR:
            return NSLocalizedString("Augmented Reality", comment: "Detail Result Table View Mode")
        case .normal:
            return NSLocalizedString("Default", comment: "Detail Result Table View Mode")
        }
    }
}

public final class DetailListCell: UITableViewCell {
    @IBOutlet var toggleButton: ToggleButton!
    @IBOutlet var primaryLabel: UILabel!
    @IBOutlet var secondaryLabel: UILabel!
    @IBOutlet var tertiaryLabel: UILabel!
}

public final class DetailListController: UITableViewController {
    
    public var currentSelection: (title: String, selection: Database.Selection)? {
        didSet {
            updateList()
        }
    }
    
    private var results: [TrainResult] = []
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Database.shared.registerForChanges(item: self) { [weak self] in
            self?.updateList()
        }
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = results[indexPath.row]
        let identifier = "DetailListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DetailListCell
        cell?.primaryLabel?.text = entry.duration.humanReadable
        cell?.tertiaryLabel.text = DateFormatter.localizedString(from: entry.date, dateStyle: .medium, timeStyle: .medium)
        let formatString = NSLocalizedString("Length: %i [%@ %@]",
                                             comment: "Detail Result Table detail text label format string. Length, difficulty, mode")
        let s = String(format: formatString, entry.configuration.length,
                       entry.configuration.difficulty.name,
                       entry.configuration.mode.name)
        cell?.secondaryLabel?.text = s
        cell?.toggleButton.value = entry.stared
        cell?.toggleButton.handler = { b in
            var updatedEntry = entry
            updatedEntry.stared = b
            Database.shared.toggleStarResult(result: updatedEntry)
            self.updateList()
        }
        return cell!
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        Database.shared.removeResult(result: results[indexPath.row])
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowResult", sender: results[indexPath.row])
    }
    
    private func updateList() {
        if let selection = currentSelection {
            results = Database.shared.trainResults(selection: selection.selection)
        } else {
            results = []
        }
        tableView.reloadData()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultController = segue.destination as? ResultController {
            resultController.result = sender as? TrainResult
        }
    }
}
