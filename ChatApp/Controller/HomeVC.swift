//
//  HomeVC.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Variables
    private var chatTitle: String?
    private var viewModel: ChatsViewModel!
    private var chat: Chats!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // init viewModel
        viewModel = ChatsViewModel(delegate: self)
        
        // Show a loading and fetch data
        Loading.shared.showProgressView(view)
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let img = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = img
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        self.viewModel.fetchChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // set back navigation bar border
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
        
        if viewModel != nil {
            viewModel.removeListener()
        }
    }
    
    deinit {
        if viewModel != nil {
            viewModel.removeListener()
        }
    }
    
    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueIdentifier(for: segue) == .ChatVC, let destinationVC = segue.destination as? ChatVC {
            destinationVC.chatTitle = self.chatTitle
            destinationVC.user = viewModel.currentUser
            destinationVC.chat = self.chat
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let chatType = viewModel.chatType(at: indexPath.row)
                destinationVC.chatType = chatType
                
                if let cell = tableView.cellForRow(at: indexPath) as? ChatCell {
                    destinationVC.userImage = cell.profileImgView.image?.image(scaledTo: CGSize(width: 40, height: 40))?.roundImage()
                }
            }
            
        } else if segueIdentifier(for: segue) == .CreateChatVC, let destinationVC = segue.destination as? CreateChatVC {
            destinationVC.chatCreated = {[unowned self] (chat, title) in
                self.chatTitle = title
                self.chat = chat
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func addBtnTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: .CreateChatVC, sender: nil)
    }
    
    @IBAction func editBtnTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)

            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.navigationItem.rightBarButtonItem?.style = .plain
        } else {
            tableView.setEditing(true, animated: true)

            self.navigationItem.rightBarButtonItem?.style = .done
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }
}

// MARK: - TableView DataSource
extension HomeVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell else {
            return ChatCell()
        }
        
        let row = indexPath.row
        
        viewModel.getUserProfileImage(at: row) { (url) in
            cell.configureImages(with: url)
        }
        
        let chat = viewModel.chat(at: row)
        let chatTitle = viewModel.chatTitle(at: row)
        cell.configureCell(chat: chat, title: chatTitle)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - TableView Delegate
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chat = viewModel.chat(at: indexPath.row)
        self.chatTitle = viewModel.chatTitle(at: indexPath.row)
        performSegue(withIdentifier: .ChatVC, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Edit and delete rows
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (action, indexPath) in
            // delete item at indexPath
            let chat = self.viewModel.chat(at: indexPath.row)
            self.viewModel.deleteChat(with: chat)
        }
        return [delete]
    }
}

// MARK: - Segue
extension HomeVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case ChatVC
        case CreateChatVC
    }
}

extension HomeVC: ChatsViewModelDelegate {
    func onFetchCompleted(with index: Int) {
        Loading.shared.hideProgressView()
        tableView.reloadData()
        
        if tableView.backgroundView != nil {
            tableView.backgroundView = nil
        }
    }
    
    func onUpdateCompleted(with index: Int) {
        tableView.reloadData()
    }
    
    func onRemoveCompleted(with index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        Loading.shared.hideProgressView()
        print("Couldn't Fetch Chats with reason: ", reason)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        label.text = "Create a new converstation by tapping '+'"
        label.textColor = .darkGray
        label.textAlignment = .center
        tableView.backgroundView = label
    }
}
