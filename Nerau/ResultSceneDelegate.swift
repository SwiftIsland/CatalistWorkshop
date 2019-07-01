import UIKit
import NerauModel

class ResultSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // just for show, load a default result
        let defaultResult = Database.shared.trainResults(selection: Database.Selection(false)).first!
        (window?.rootViewController as? ResultController)?.result = decodeUserActivity(from: connectionOptions, session: session) ?? defaultResult
    }
    
    private func decodeUserActivity(from options: UIScene.ConnectionOptions, session: UISceneSession) -> TrainResult? {
        // Pull together the information for setting up the new window
        guard let userActivity = options.userActivities.first ?? session.stateRestorationActivity else {
            print("Could not setup scene, missing result")
            return nil
        }
        
        guard userActivity.activityType == ResultOpenDetailActivityType else {
            print("Invalid activity type")
            return nil
        }
        
        guard let resultKey = userActivity.userInfo?[ResultOpenTrainResultKey] as? String else {
            print("Missing train result")
            return nil
        }
        
        guard let result = (UIApplication.shared.delegate as? AppDelegate)?.sceneResult(for: resultKey) else {
            print("Invalid Key")
            return nil
        }
        
        return result
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
}

