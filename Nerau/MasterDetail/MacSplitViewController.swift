//
//  MacSplitViewController.swift
//  Nerau
//
//  Created by terhechte on 23.06.19.
//  Copyright © 2019 Benedikt Terhechte. All rights reserved.
//

import UIKit
import NerauModel

class MacSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    #if targetEnvironment(UIKitForMac)
    static let NewTrainingItemTouchbarIdentifier = NSTouchBarItem.Identifier(rawValue: "NewTraining")
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        self.minimumPrimaryColumnWidth = 150
        self.maximumPrimaryColumnWidth = 300
        self.primaryBackgroundStyle = .sidebar
        view.addInteraction(UIDropInteraction(delegate: self))
        #else
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        #endif
    }
    
    @objc func doBeginNewTraining(sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.startTraining(configuration: nil)
    }
    
    #if !targetEnvironment(UIKitForMac)
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    #endif
    
    #if targetEnvironment(UIKitForMac)
    
    @IBAction func storeResult(sender: Any?) {
        /// We forward from here to the actual implementation iff `canPerformAction` returned true
        ((viewControllers.last as? UINavigationController)?.visibleViewController as? ResultController)?.storeResult(sender: sender)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        /// This is where we really want a `Coordinator` or `Presenter` or anything, really, with a `Router` pattern
        /// So that we know the current state of the UI. We need to know whether a `ResultController` is currently
        /// being displayed.
        if action == Selector(("storeResultWithSender:")) {
            return ((viewControllers.last as? UINavigationController)?.visibleViewController is ResultController)
        }
        return super.canPerformAction(action, withSender: sender)
    }
    #endif
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
