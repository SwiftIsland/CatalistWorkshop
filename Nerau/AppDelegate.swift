//
//  AppDelegate.swift
//  Nerau
//
//  Created by Benedikt Terhechte on 18.06.19.
//  Copyright © 2019 Benedikt Terhechte. All rights reserved.
//

import UIKit
import NerauModel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if Database.shared.numberOfTrainResults() == 0 {
            Database.shared.generateFakeData(number: 100)
        }
        Database.shared.errorDelegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Menu Actions
    
    @IBAction func beginEasyTraining(sender: UIMenuItem?) {
        startTraining(configuration: TrainConfiguration(difficulty: .easy, length: 10, mode: .normal))
    }
    
    func startTraining(configuration: TrainConfiguration?) {
        let window = UIApplication.shared.keyWindow
        guard let controller = window?.rootViewController?.storyboard?.instantiateViewController(identifier: "ResultController") as? TrainingViewController else { fatalError() }
        
        controller.modalPresentationStyle = .formSheet
        (window?.rootViewController as? UITabBarController)?.viewControllers?[0].present(controller, animated: true, completion: {
            if let config = configuration {
                controller.beginTrainingWithConfiguration(configuration: config)
            }
        })
    }
}

extension AppDelegate: UIErrorHandler {
    func displayError(message: String) {
        let alert = UIAlertController(title: "Data Error", message: message,
                                      preferredStyle: .alert)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
