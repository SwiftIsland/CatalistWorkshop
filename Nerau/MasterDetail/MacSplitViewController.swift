//
//  MacSplitViewController.swift
//  Nerau
//
//  Created by terhechte on 23.06.19.
//  Copyright © 2019 Benedikt Terhechte. All rights reserved.
//

import UIKit

class MacSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(UIKitForMac)
        self.minimumPrimaryColumnWidth = 50
        self.maximumPrimaryColumnWidth = 300
        self.primaryBackgroundStyle = .sidebar
        #endif
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
