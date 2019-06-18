import UIKit

public class ListController<T>: UITableViewController {
    public var defaultCellReuseIdentifier = "Cell"
    /// Format the cell
    public lazy var cellFormatter: ((_ value: T, _ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell)? = { (value, indexPath, tableView) in
        let cell = tableView.dequeueReusableCell(withIdentifier: "durationCell")!
        cell.textLabel?.text = "\(value)"
        return cell
    }
    
    /// Called for each selection. Return false if selection should not be allowed
    public var canSelectHandler: ((_ value: T, _ indexPath: IndexPath) -> Bool)?
    
    /// Should the controller be dismissed on selection? (`canSelectHandler` will still be called)
    public var dismissOnSelection: Bool = false
    
    /// Override with another closure to specialize cell registration. Default is `UITableViewCell` with `.defaultCellReuseIdentifier`
    public lazy var cellRegistration: ((_ tableView: UITableView) -> Void)? = { tableView in
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.defaultCellReuseIdentifier)
    }
    
    public var data: [T] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(values: [T], style: UITableView.Style) {
        data = values
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        cellRegistration?(tableView)
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellFormatter!(data[indexPath.row], indexPath, tableView)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let handler = canSelectHandler else { return nil }
        guard handler(data[indexPath.row], indexPath) else { return nil }
        return indexPath
    }
}
