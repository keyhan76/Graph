//
//  SettingsChildVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/10/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class SettingsChildVC: UITableViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                parent?.performSegue(withIdentifier: "AboutusVC", sender: nil)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                DataService.shared.signOut()
                showSplashVC()
            }
        }
    }
    
    // MARK: - Helpers
    private func showSplashVC() {
        let vc: SplashVC = UIStoryboard(storyboard: .main).instantiateViewController()

        VCDismisser.shared.animateTovc(viewControllerToAnimate: vc, vctoDissmiss: self)
    }
}
