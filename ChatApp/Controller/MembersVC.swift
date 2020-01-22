//
//  MembersVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/4/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class MembersVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Variables
    private var members = [String]()
    
    // MARK: - Public Variables
    public var viewModel: CreateChatViewModel!
    public var chatTitle: String!
    public var createdChat: ((_ chat: Chats) -> ())?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
    }

    // MARK: - Actions
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        // create the group chat
        
        // append creator user id to members array
        guard let user = viewModel.currentUser else { return }
        members.append(user.uid)
        
        let chat = Chats(user: user, title: chatTitle, lastMessage: nil, members: members)
        
        createdChat?(chat)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Add Switch action
    @objc fileprivate func addSwitchTapped(_ sender: UISwitch) {
        // if switch is on then append id to the array
//        if sender.isOn == true {
//            let userId = viewModel.user(at: sender.tag).id ?? "No id"
//            members.append(userId)
//        } else {
//            // if switch is off then remove id from array
//            members.remove(at: sender.tag)
//        }
    }
}
// MARK: - TableView DataSource
extension MembersVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalUserCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersCell", for: indexPath)
        cell.textLabel?.text = viewModel.user(at: indexPath.row).name
        cell.detailTextLabel?.text = "@\(viewModel.user(at: indexPath.row).username ?? "")"
        
        let userId = viewModel.user(at: indexPath.row).id ?? ""
        
        if members.contains(userId) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - TableView Delegate
extension MembersVC: UITableViewDelegate {
    // Create the switch for cells
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Create status switch
//        let addSwitch = UISwitch(frame: CGRect(x: 254, y: 14, width: 51, height: 31))
//        addSwitch.tag = indexPath.row
//        addSwitch.addTarget(self, action: #selector(addSwitchTapped), for: .valueChanged)
//        cell.accessoryType = .checkmark
//
//        let userId = viewModel.user(at: indexPath.row).id ?? ""
//
//        if members.contains(userId) {
//            addSwitch.isOn = true
//        } else {
//            addSwitch.isOn = false
//        }
        
//        if menu[indexPath.row].status == true {
//            foodSwitch.isOn = true
//        } else {
//            foodSwitch.isOn = false
//        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .some(.none) {
            let userId = viewModel.user(at: indexPath.row).id ?? "No id"
            members.append(userId)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else if tableView.cellForRow(at: indexPath)?.accessoryType == .some(.checkmark) {
            // if switch is off then remove id from array
            members.remove(at: indexPath.row)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
