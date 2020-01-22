//
//  ProfileVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/7/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    
    // MARK: - Private Variables
    private var isEqual: Bool = false
    private var viewModel: UserViewModel!
    private var newUsername: String!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doneBtn.isEnabled = false
    }
    
    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueIdentifier(for: segue) == .ProfileChildVC, let destinationVC = segue.destination as? ProfileChildVC {
            destinationVC.editedProfile = {[unowned self] (username, newUsername, viewModel) in
                self.isEqual = username.elementsEqual(newUsername)
                self.doneBtn.isEnabled = !self.isEqual
                self.viewModel = viewModel
                self.newUsername = newUsername
            }
        }
    }
    
    @IBAction func doneBtnTapped(_ sender: UIBarButtonItem) {
        // if username has changed then save the changes
        if !isEqual {
            view.endEditing(true)
            Loading.shared.showProgressView(children.first!.view)
            viewModel.updateUsername(with: newUsername)
            doneBtn.isEnabled = false
        }
    }

}

// MARK: - Segue
extension ProfileVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case ProfileChildVC
    }
}
