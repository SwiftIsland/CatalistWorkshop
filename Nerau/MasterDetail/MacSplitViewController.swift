//
//  MacSplitViewController.swift
//  Nerau
//
//  Created by terhechte on 23.06.19.
//  Copyright © 2019 Benedikt Terhechte. All rights reserved.
//

import UIKit

class MacSplitViewController: UISplitViewController {
    
    static let NewTrainingItemTouchbarIdentifier = NSTouchBarItem.Identifier(rawValue: "NewTraining")

    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        self.minimumPrimaryColumnWidth = 50
        self.maximumPrimaryColumnWidth = 300
        self.primaryBackgroundStyle = .sidebar
        #endif
    }
    
    @objc func doBeginNewTraining(sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.startTraining(configuration: nil)
    }
}

#if targetEnvironment(UIKitForMac)
extension MacSplitViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [MacSplitViewController.NewTrainingItemTouchbarIdentifier]
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        // Note: 'NSImageNameTouchBarAddTemplate' is unavailable in UIKit for Mac
        switch identifier {
        case MacSplitViewController.NewTrainingItemTouchbarIdentifier:
            return NSButtonTouchBarItem.init(identifier: identifier,
                                             title: "New Training",
                                             target: self,
                                             action: #selector(self.doBeginNewTraining))
        default: return nil
        }
    }
}

#endif
