import UIKit
import NerauModel

public final class SidebarCell: UITableViewCell {
    @IBOutlet var badgeLabel: UILabel! {
        didSet {
            /// We want to change the badge color to something more akin to macOS
            #if targetEnvironment(UIKitForMac)
            badgeLabel.textColor = UIColor.secondaryLabel
            badgeLabel.font = UIFont.preferredFont(forTextStyle: .body)
            #endif
        }
    }
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            /// Set the correct font for sidebars on macOS
            #if targetEnvironment(UIKitForMac)
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
            #endif
        }
    }
    @IBOutlet var badgeBackgroundView: UIView! {
        didSet {
            /// Badge backgrounds are out on macOS
            #if targetEnvironment(UIKitForMac)
            badgeBackgroundView.backgroundColor = nil
            #endif
        }
    }
    var cornerRadius: Int = 0 {
        didSet {
            badgeBackgroundView?.layer.cornerRadius = CGFloat(self.cornerRadius)
        }
    }
}

extension Date {
    static func pastMonth(months: Int) -> Date {
        return Calendar.current.date(byAdding: Calendar.Component.month, value: -months, to: Date())!
    }
}

public final class SidebarController: UITableViewController {
    
    struct SidebarSection {
        let title: String
        let entries: [SidebarEntry]
        
        init(_ title: String, _ entries: SidebarEntry...) {
            self.title = title
            self.entries = entries
        }
    }
    
    struct SidebarEntry {
        let title: String
        let selection: Database.Selection
    }
    
    private var structure: [SidebarSection] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        navigationController?.setNavigationBarHidden(true, animated: false)
        #endif
        Database.shared.registerForChanges(item: self) { [weak self] in
            self?.updateStructure()
        }
        updateStructure()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return structure.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return structure[section].title
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structure[section].entries.count
    }

    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = structure[indexPath.section].entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SidebarCell") as! SidebarCell
        cell.cornerRadius = 16
        cell.badgeLabel.text = "\(Database.shared.numberOfTrainResults(selection: entry.selection))"
        cell.titleLabel.text = entry.title
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = structure[indexPath.section].entries[indexPath.row]
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            guard let controller = storyboard?.instantiateViewController(identifier: "DetailList")
                as? DetailListController
                else { return }
            splitViewController?.showDetailViewController(controller, sender: nil)
            controller.currentSelection = (entry.title, entry.selection)
        } else {
            ((splitViewController?
                .viewControllers[1] as? UINavigationController)?
                .topViewController as? DetailListController)?
                .currentSelection = (entry.title, entry.selection)
        }
    }
    
    private func updateStructure() {
        // Update with current date
        structure = [SidebarSection("By Date",
                                    SidebarEntry(title: "This Month",
                                                 selection: .init(.pastMonth(months: 1))),
                                    SidebarEntry(title: "Past 3 Month",
                                                 selection: .init(.pastMonth(months: 3))),
                                    SidebarEntry(title: "Past 6 Month",
                                                 selection: .init(.pastMonth(months: 6))),
                                    SidebarEntry(title: "Past Year",
                                                 selection: .init(.pastMonth(months: 12)))),
                     SidebarSection("By Difficulty",
                                    SidebarEntry(title: "Easy",
                                                 selection: .init(.easy)),
                                    SidebarEntry(title: "Medium",
                                                 selection: .init(.medium)),
                                    SidebarEntry(title: "Hard",
                                                 selection: .init(.hard)),
                                    SidebarEntry(title: "Insane",
                                                 selection: .init(.insane))),
                     SidebarSection("Other",
                                    SidebarEntry(title: "Stared", selection: .init(true))
                                    )
        ]
        tableView.reloadData()
    }
}
