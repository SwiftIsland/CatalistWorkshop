//
//  MacSplitViewController.swift
//  Nerau
//
//  Created by terhechte on 23.06.19.
//  Copyright © 2019 Benedikt Terhechte. All rights reserved.
//

import UIKit
import NerauModel

class MacSplitViewController: UISplitViewController {
    
    static let NewTrainingItemTouchbarIdentifier = NSTouchBarItem.Identifier(rawValue: "NewTraining")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        self.minimumPrimaryColumnWidth = 50
        self.maximumPrimaryColumnWidth = 300
        self.primaryBackgroundStyle = .sidebar
        view.addInteraction(UIDropInteraction(delegate: self))
        #endif
    }
    
    @objc func doBeginNewTraining(sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.startTraining(configuration: nil)
    }
}

#if targetEnvironment(UIKitForMac)

extension MacSplitViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: ["public.json"])
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type UIImage).
        session.loadObjects(ofClass: NSURL.self) { imageItems in
            guard let urls = imageItems as? [NSURL] else { return }
            var lastResult: TrainResult?
            for url in urls {
                do {
                    let data = try Data(contentsOf: url as URL)
                    let object = try Database.shared.importFromJSON(data: data)
                    lastResult = object
                } catch let error {
                    print("Drag and drop import error: \(error)")
                }
            }
            if let result = lastResult {
                (UIApplication.shared.delegate as? AppDelegate)?.openResult(result: result)
            }
        }
    }
}

extension MacSplitViewController: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [MacSplitViewController.NewTrainingItemTouchbarIdentifier,
                                           NSTouchBarItem.Identifier.otherItemsProxy]
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
