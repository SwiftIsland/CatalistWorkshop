import UIKit
import NerauModel

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    #if targetEnvironment(UIKitForMac)
    static let SegmentedItemToolbarIdentifier = NSToolbarItem.Identifier(rawValue: "PrimaryGroup")
    static let NewTrainingItemToolbarIdentifier = NSToolbarItem.Identifier(rawValue: "NewTraining")
    #endif
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(UIKitForMac)
        if let windowScene = scene as? UIWindowScene {
            if let titlebar = windowScene.titlebar {
                let toolbar = NSToolbar(identifier: "NerauToolbar")

                let rootViewController = window?.rootViewController as? UITabBarController
                rootViewController?.tabBar.isHidden = true

                toolbar.delegate = self
                toolbar.centeredItemIdentifier = SceneDelegate.SegmentedItemToolbarIdentifier
                titlebar.titleVisibility = .hidden

                titlebar.toolbar = toolbar
            }
        }
        #endif
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    @objc func doBeginNewTraining(sender: UIBarButtonItem) {
        (UIApplication.shared.delegate as? AppDelegate)?.startTraining(configuration: nil)
    }
}

#if targetEnvironment(UIKitForMac)
extension SceneDelegate: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if (itemIdentifier == SceneDelegate.SegmentedItemToolbarIdentifier) {
            let group = NSToolbarItemGroup(itemIdentifier: SceneDelegate.SegmentedItemToolbarIdentifier,
                                           titles: ["Train", "Community"],
                                           selectionMode: .selectOne,
                                           labels: ["section1", "section2"],
                                           target: self,
                                           action: #selector(toolbarGroupSelectionChanged))
            
            group.setSelected(true, at: 0)
            
            return group
        }
        if (itemIdentifier == SceneDelegate.NewTrainingItemToolbarIdentifier) {
            let button = NSToolbarItem(itemIdentifier: SceneDelegate.NewTrainingItemToolbarIdentifier, barButtonItem: UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.doBeginNewTraining(sender:))))
            return button
        }
        
        return nil
    }
    
    @objc func toolbarGroupSelectionChanged(sender: NSToolbarItemGroup) {
        let rootViewController = window?.rootViewController as? UITabBarController
        rootViewController?.selectedIndex = sender.selectedIndex
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [SceneDelegate.SegmentedItemToolbarIdentifier,
                NSToolbarItem.Identifier.flexibleSpace,
                SceneDelegate.NewTrainingItemToolbarIdentifier]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
}
#endif
