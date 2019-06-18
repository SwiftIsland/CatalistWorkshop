import UIKit

public struct CommunityUser: Codable {
    var id: Int
    var firstName: String
    var lastName: String
    var points: Int
    var lastTraining: Date
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case lastTraining = "last_training"
        case id, points
    }
}

public final class CommunityViewController: UITableViewController {
    
    enum CommunityError: Error {
        case empty
        case unauthorized
        case other(String)
        
        var localizedDescription: String {
            switch self {
            case .empty:
                return NSLocalizedString("Did not receive data from server", comment: "If the server response is invalid in `Community`")
            case .unauthorized:
                return NSLocalizedString("You're not authorized connect to the server", comment: "If the server response is invalid in `Community`")
            case .other(let message):
                return String(format: NSLocalizedString("HTTP Error: %s", comment: "If the server response is invalid in `Community`"), message)
            }
        }
    }
    
    private var users: [CommunityUser] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        cell.detailTextLabel?.text = "Points: \(user.points), Last: \(DateFormatter.localizedString(from: user.lastTraining, dateStyle: .medium, timeStyle: .medium))"
        return cell
    }
    
    private func displayError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    private func loadData() {
        let bundleIdentifier =  Bundle.main.bundleIdentifier!
        var request = URLRequest(url: URL(string: "http://nerau.stylemac.com")!)
        request.addValue(bundleIdentifier, forHTTPHeaderField: "x-nerau-client")
        let c = URLSession(configuration: URLSessionConfiguration.ephemeral).dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                return self.displayError(error!)
            }
            guard let data = data else {
                return self.displayError(CommunityError.empty)
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let entries = try decoder.decode([CommunityUser].self, from: data)
                DispatchQueue.main.async {
                    self.users = entries
                }
            } catch let error {
                return self.displayError(error)
            }
        }
        c.resume()
    }
}
