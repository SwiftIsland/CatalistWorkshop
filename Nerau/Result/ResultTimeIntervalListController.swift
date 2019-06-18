import UIKit

final class ResultTimeIntervalListController: UITableViewController {
    public var dataPoints: [TimeInterval] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "durationCell")
        cell?.detailTextLabel?.text = dataPoints[indexPath.row].humanReadable
        cell?.textLabel?.text = "Duration"
        return cell!
    }
}
